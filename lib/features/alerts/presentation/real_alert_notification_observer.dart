import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../forecasts/providers/forecast_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../../settings/providers/alert_preferences_provider.dart';
import '../data/local_alert_notification_service.dart';
import '../domain/alert_engine.dart';
import '../domain/safe_alert_engine.dart';

class RealAlertNotificationObserver extends ConsumerStatefulWidget {
  final Widget child;

  const RealAlertNotificationObserver({super.key, required this.child});

  @override
  ConsumerState<RealAlertNotificationObserver> createState() =>
      _RealAlertNotificationObserverState();
}

class _RealAlertNotificationObserverState
    extends ConsumerState<RealAlertNotificationObserver> {
  String? _processingKey;
  String? _processedKey;

  Future<void> _sendNotifications({
    required SafeAlertResult report,
    required String cityId,
    required String cityName,
    required String key,
  }) async {
    try {
      final service = LocalAlertNotificationService.instance;

      if (!await service.isEnabled()) {
        return;
      }

      if (!mounted) {
        return;
      }

      final predictiveEnabled =
          ref.read(predictiveAlertsEnabledProvider).asData?.value == true;

      if (!predictiveEnabled) {
        return;
      }

      await service.notifyForReport(
        report: report,
        cityId: cityId,
        cityName: cityName,
        predictiveAlertsEnabled: predictiveEnabled,
      );

      _processedKey = key;
    } catch (error) {
      debugPrint('Falha ao verificar notificações ambientais: $error');
    } finally {
      if (_processingKey == key) {
        _processingKey = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictivePreference = ref.watch(predictiveAlertsEnabledProvider);

    if (predictivePreference.asData?.value != true) {
      return widget.child;
    }

    final cityState = ref.watch(selectedCityProvider);
    final forecastState = ref.watch(forecastProvider);
    final cacheStatuses = ref.watch(cacheStatusProvider);

    final city = cityState.asData?.value;
    final forecast = forecastState.asData?.value;

    if (city == null || forecast == null || forecastState.isLoading) {
      return widget.child;
    }

    final cacheStatus =
        cacheStatuses[EnvironmentCacheKeys.status(city, 'forecast')];

    if (cacheStatus == null || cacheStatus.fromCache) {
      return widget.child;
    }

    final report = SafeAlertEngine.evaluate(
      forecast,
      fromCache: cacheStatus.fromCache,
    );

    if (!report.canDisplayAlerts || report.demonstration) {
      return widget.child;
    }

    final eligibleAlerts = report.alerts
        .where(
          (alert) =>
              alert.priority == AlertPriority.elevada ||
              alert.priority == AlertPriority.critica,
        )
        .toList();

    if (eligibleAlerts.isEmpty) {
      return widget.child;
    }

    final key = [
      city.id.toString(),
      report.sourceTime.toIso8601String(),
      for (final alert in eligibleAlerts)
        '${alert.id}:${alert.peakTime.toIso8601String()}',
    ].join('|');

    if (_processingKey != key && _processedKey != key) {
      _processingKey = key;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _processingKey = null;
          return;
        }

        _sendNotifications(
          report: report,
          cityId: city.id.toString(),
          cityName: city.name,
          key: key,
        );
      });
    }

    return widget.child;
  }
}
