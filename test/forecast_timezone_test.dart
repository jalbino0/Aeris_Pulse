import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';
import 'package:aeris_pulse/features/alerts/domain/alert_engine.dart';
import 'package:aeris_pulse/features/alerts/domain/safe_alert_engine.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_data.dart';
import 'package:aeris_pulse/features/forecasts/domain/forecast_analysis.dart';

final referenceUtc = DateTime.utc(2026, 11, 9, 23);

Map<String, dynamic> buildForecastResponse({
  required String timezone,
  required int utcOffsetSeconds,
}) {
  final referenceTimestamp = referenceUtc.millisecondsSinceEpoch ~/ 1000;

  final times = List<int>.generate(
    96,
    (index) => referenceTimestamp + (index - 23) * 3600,
  );

  return {
    'timezone': timezone,
    'utc_offset_seconds': utcOffsetSeconds,
    'current': {'time': referenceTimestamp},
    'hourly': {
      'time': times,
      'pm2_5': List<double>.filled(96, 65),
      'pm10': List<double>.filled(96, 110),
      'ozone': List<double>.filled(96, 140),
    },
  };
}

void main() {
  group('Fusos horários das previsões', () {
    test('São Paulo utiliza UTC-3', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Sao_Paulo',
          utcOffsetSeconds: -10800,
        ),
      );

      expect(data.timezone, 'America/Sao_Paulo');
      expect(data.utcOffsetSeconds, -10800);
      expect(data.referenceTime.hour, 20);
      expect(data.referenceTime.day, 9);
      expect(data.hours.length, 96);
    });

    test('Manaus utiliza UTC-4', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Manaus',
          utcOffsetSeconds: -14400,
        ),
      );

      expect(data.timezone, 'America/Manaus');
      expect(data.utcOffsetSeconds, -14400);
      expect(data.referenceTime.hour, 19);
      expect(data.referenceTime.day, 9);
    });

    test('Rio Branco utiliza UTC-5', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Rio_Branco',
          utcOffsetSeconds: -18000,
        ),
      );

      expect(data.timezone, 'America/Rio_Branco');
      expect(data.utcOffsetSeconds, -18000);
      expect(data.referenceTime.hour, 18);
      expect(data.referenceTime.day, 9);
    });

    test('as cidades mantêm o mesmo instante de referência', () {
      final saoPaulo = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Sao_Paulo',
          utcOffsetSeconds: -10800,
        ),
      );

      final manaus = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Manaus',
          utcOffsetSeconds: -14400,
        ),
      );

      final rioBranco = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Rio_Branco',
          utcOffsetSeconds: -18000,
        ),
      );

      final saoPauloUtc = saoPaulo.referenceTime.subtract(
        Duration(seconds: saoPaulo.utcOffsetSeconds),
      );

      final manausUtc = manaus.referenceTime.subtract(
        Duration(seconds: manaus.utcOffsetSeconds),
      );

      final rioBrancoUtc = rioBranco.referenceTime.subtract(
        Duration(seconds: rioBranco.utcOffsetSeconds),
      );

      expect(saoPauloUtc, manausUtc);
      expect(manausUtc, rioBrancoUtc);
      expect(saoPauloUtc, referenceUtc);
    });

    test('médias móveis preservam os valores previstos', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Manaus',
          utcOffsetSeconds: -14400,
        ),
      );

      final average = ForecastAnalysis.rollingAverage(
        data,
        PoluenteBr.mp25,
        data.referenceTime,
      );

      expect(average, isNotNull);
      expect(average!, closeTo(65, 0.01));
    });
  });

  group('Segurança dos alertas em diferentes fusos', () {
    for (final city in [
      ('São Paulo', 'America/Sao_Paulo', -10800),
      ('Manaus', 'America/Manaus', -14400),
      ('Rio Branco', 'America/Rio_Branco', -18000),
    ]) {
      test('${city.$1} aceita previsões futuras válidas', () {
        final data = ForecastData.fromJson(
          buildForecastResponse(timezone: city.$2, utcOffsetSeconds: city.$3),
        );

        final result = SafeAlertEngine.evaluate(data, now: referenceUtc);

        expect(result.status, AlertDataStatus.ready);
        expect(result.isReady, isTrue);
        expect(result.validFuturePoints, 72);
        expect(result.horizonHours, 72);
      });
    }

    test('previsões antigas continuam bloqueadas', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Manaus',
          utcOffsetSeconds: -14400,
        ),
      );

      final result = SafeAlertEngine.evaluate(
        data,
        now: referenceUtc.add(const Duration(hours: 5)),
      );

      expect(result.status, AlertDataStatus.expired);
      expect(result.isReady, isFalse);
      expect(result.alerts, isEmpty);
    });

    test('cache válido permanece identificado como offline', () {
      final data = ForecastData.fromJson(
        buildForecastResponse(
          timezone: 'America/Rio_Branco',
          utcOffsetSeconds: -18000,
        ),
      );

      final result = SafeAlertEngine.evaluate(
        data,
        now: referenceUtc,
        fromCache: true,
      );

      expect(result.isReady, isTrue);
      expect(result.fromCache, isTrue);
      expect(result.statusTitle, 'Prévia armazenada');
    });

    test('demonstração não depende do fuso do dispositivo', () {
      final data = DemonstrationForecast.create(
        referenceTime: DateTime(2026, 11, 9, 12),
      );

      final result = SafeAlertEngine.evaluate(
        data,
        now: DateTime.utc(2035, 1, 1),
        demonstration: true,
      );

      expect(result.status, AlertDataStatus.ready);
      expect(result.demonstration, isTrue);
      expect(result.confidenceLevel, 'Não aplicável');
    });
  });
}
