
import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/features/alerts/domain/alert_engine.dart';
import 'package:aeris_pulse/features/alerts/domain/safe_alert_engine.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_data.dart';

void main() {
  final reference = DateTime(2026, 11, 8, 12);
  final now = DateTime.utc(2026, 11, 8, 15, 20);

  test('Aceita uma previsão recente com horas futuras', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: now,
      demonstration: true,
    );

    expect(result.status, AlertDataStatus.ready);
    expect(result.isReady, isTrue);
    expect(result.alerts, isNotEmpty);
    expect(result.validFuturePoints, greaterThanOrEqualTo(6));
  });

  test('Não gera alertas para previsões expiradas', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: DateTime.utc(2026, 11, 9, 15, 20),
    );

    expect(result.status, AlertDataStatus.expired);
    expect(result.alerts, isEmpty);
  });

  test('Bloqueia previsões sem horas futuras', () {
    final data = ForecastData(
      referenceTime: reference,
      hours: [
        ForecastHour(
          time: DateTime(2026, 11, 8, 10),
          pm25: 20,
          pm10: 30,
          ozone: 50,
        ),
        ForecastHour(
          time: DateTime(2026, 11, 8, 11),
          pm25: 20,
          pm10: 30,
          ozone: 50,
        ),
      ],
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: now,
    );

    expect(result.status, AlertDataStatus.noFutureData);
    expect(result.alerts, isEmpty);
  });

  test('Rejeita previsões com poucas médias válidas', () {
    final data = ForecastData(
      referenceTime: reference,
      hours: [
        ForecastHour(
          time: DateTime(2026, 11, 8, 13),
          pm25: 60,
          pm10: 110,
          ozone: 140,
        ),
      ],
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: now,
    );

    expect(result.status, AlertDataStatus.insufficientData);
    expect(result.alerts, isEmpty);
  });

  test('Identifica uma análise feita com cache recente', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: now,
      fromCache: true,
    );

    expect(result.status, AlertDataStatus.ready);
    expect(result.fromCache, isTrue);
    expect(result.alerts, isNotEmpty);
  });

  test('Não permite previsões com referência no futuro distante', () {
    final futureReference = DateTime(2026, 11, 8, 18);

    final data = DemonstrationForecast.create(
      referenceTime: futureReference,
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: now,
    );

    expect(result.status, AlertDataStatus.expired);
    expect(result.alerts, isEmpty);
  });

  test('Todos os alertas possuem pico posterior ao horário atual', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final result = SafeAlertEngine.evaluate(
      data,
      now: DateTime.utc(2026, 11, 8, 18, 20),
    );

    expect(result.status, AlertDataStatus.ready);

    final currentWall = DateTime.utc(2026, 11, 8, 15, 20);

    for (final alert in result.alerts) {
      final peak = DateTime.utc(
        alert.peakTime.year,
        alert.peakTime.month,
        alert.peakTime.day,
        alert.peakTime.hour,
        alert.peakTime.minute,
      );

      expect(peak.isAfter(currentWall), isTrue);
    }
  });

  test('Rejeita horizonte de previsão inválido', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    expect(
      () => SafeAlertEngine.evaluate(
        data,
        now: now,
        horizonHours: 0,
      ),
      throwsArgumentError,
    );
  });
}
