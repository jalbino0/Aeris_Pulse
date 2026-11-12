import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/alert_engine.dart';
import '../domain/safe_alert_engine.dart';

class LocalAlertNotificationService {
  LocalAlertNotificationService._();

  static final LocalAlertNotificationService instance =
      LocalAlertNotificationService._();

  static const String _enabledKey = 'aeris_local_notifications_enabled';
  static const String _sentAlertsKey = 'aeris_sent_alert_notifications';

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'aeris_environmental_alerts',
      'Alertas ambientais',
      channelDescription:
          'Notificações sobre possíveis condições de atenção '
          'previstas para a qualidade do ar.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initialization;
  void Function(String)? _onNotificationTap;

  void setOnNotificationTap(void Function(String)? callback) {
    _onNotificationTap = callback;
  }

  Future<void> initialize() {
    return _initialization ??= _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          _onNotificationTap?.call(payload);
        }
      },
    );
  }

  Future<String?> getLaunchNotificationPayload() async {
    await initialize();

    final details = await _plugin.getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp != true) {
      return null;
    }

    return details?.notificationResponse?.payload;
  }

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();

    if (preferences.getBool(_enabledKey) != true) {
      return false;
    }

    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<bool> setEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();

    if (!enabled) {
      await preferences.setBool(_enabledKey, false);
      return false;
    }

    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) {
      throw UnsupportedError(
        'As notificações estão disponíveis na versão Android do Aeris Pulse.',
      );
    }

    final granted = await android.requestNotificationsPermission() ?? false;

    if (!granted) {
      await preferences.setBool(_enabledKey, false);
      return false;
    }

    return preferences.setBool(_enabledKey, true);
  }

  Future<void> showTestNotification() async {
    if (!await isEnabled()) {
      throw StateError('As notificações não estão habilitadas.');
    }

    await initialize();

    await _plugin.show(
      id: 1,
      title: 'Aeris Pulse • Notificações ativadas',
      body:
          'Este é um teste de notificação. '
          'Nenhuma condição ambiental real foi identificada.',
      notificationDetails: _notificationDetails,
      payload: 'alertas',
    );
  }

  Future<int> notifyForReport({
    required SafeAlertResult report,
    required String cityId,
    required String cityName,
    required bool predictiveAlertsEnabled,
  }) async {
    if (!predictiveAlertsEnabled ||
        !report.isReady ||
        report.demonstration ||
        report.fromCache ||
        report.alerts.isEmpty) {
      return 0;
    }

    if (!await isEnabled()) {
      return 0;
    }

    await initialize();

    final preferences = await SharedPreferences.getInstance();

    final sentAlerts =
        preferences.getStringList(_sentAlertsKey)?.toList() ?? <String>[];

    var sentCount = 0;

    for (final alert in report.alerts) {
      if (alert.priority == AlertPriority.preventiva) {
        continue;
      }

      final key = '$cityId|${alert.id}|${alert.peakTime.toIso8601String()}';

      if (sentAlerts.contains(key)) {
        continue;
      }

      final title = alert.priority == AlertPriority.critica
          ? 'Atenção crítica • $cityName'
          : 'Atenção à qualidade do ar • $cityName';

      final body =
          'Projeção de ${alert.pollutantName}: '
          'possível condição ${alert.classification.nome.toLowerCase()} '
          'nas próximas horas. '
          'Consulte as evidências e limitações no Aeris Pulse.';

      await _plugin.show(
        id: _notificationId(key),
        title: title,
        body: body,
        notificationDetails: _notificationDetails,
        payload: 'alerta:${alert.id}:$cityId',
      );

      sentAlerts.add(key);
      sentCount++;
    }

    if (sentCount > 0) {
      final recentAlerts = sentAlerts.length > 100
          ? sentAlerts.sublist(sentAlerts.length - 100)
          : sentAlerts;

      await preferences.setStringList(_sentAlertsKey, recentAlerts);
    }

    return sentCount;
  }

  int _notificationId(String value) {
    var hash = 2166136261;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return 1000 + (hash % 2000000000);
  }
}
