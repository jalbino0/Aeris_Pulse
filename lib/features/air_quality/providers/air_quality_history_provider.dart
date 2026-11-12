import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../data/air_quality_history.dart';
import '../data/air_quality_history_service.dart';

final airQualityHistoryServiceProvider = Provider<AirQualityHistoryService>((
  ref,
) {
  return AirQualityHistoryService(ref.watch(cachedApiClientProvider));
});

final airQualityHistoryProvider = FutureProvider<AirQualityHistory>((
  ref,
) async {
  final service = ref.watch(airQualityHistoryServiceProvider);
  final city = await ref.watch(selectedCityProvider.future);

  final result = await service.fetchCityHistory(city);

  if (ref.mounted) {
    final statuses = ref.read(cacheStatusProvider.notifier);

    statuses.register('history', result);
    statuses.register(EnvironmentCacheKeys.status(city, 'history'), result);
  }

  return result.data;
});
