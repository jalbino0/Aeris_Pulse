
import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_data.dart';
import 'package:aeris_pulse/features/forecasts/domain/forecast_analysis.dart';

void main() {
  final reference = DateTime(2026, 11, 7, 12);

  ForecastData createForecast() {
    final hours = List.generate(96, (index) {
      return ForecastHour(
        time: reference.add(Duration(hours: index - 23)),
        pm25: 20,
        pm10: 40,
        ozone: 80,
      );
    });

    return ForecastData(
      referenceTime: reference,
      hours: hours,
    );
  }

  test('Calcula média de 24 horas para MP2,5', () {
    final data = createForecast();

    final average = ForecastAnalysis.rollingAverage(
      data,
      PoluenteBr.mp25,
      reference.add(const Duration(hours: 12)),
    );

    expect(average, 20);
  });

  test('Calcula média de 8 horas para ozônio', () {
    final data = createForecast();

    final average = ForecastAnalysis.rollingAverage(
      data,
      PoluenteBr.ozonio,
      reference.add(const Duration(hours: 5)),
    );

    expect(average, 80);
  });

  test('Gera 24 horas futuras sem incluir o presente', () {
    final points = ForecastAnalysis.calculate(
      createForecast(),
      PoluenteBr.mp25,
      24,
    );

    expect(points.length, 24);

    expect(
      points.first.time,
      reference.add(const Duration(hours: 1)),
    );

    expect(
      points.last.time,
      reference.add(const Duration(hours: 24)),
    );

    expect(
      points.first.classification,
      FaixaQualidadeAr.moderada,
    );
  });

  test('Identifica o pico da média prevista', () {
    final data = createForecast();

    final points = ForecastAnalysis.calculate(
      data,
      PoluenteBr.mp25,
      48,
    );

    final peak = ForecastAnalysis.peak(points);

    expect(peak, isNotNull);
    expect(peak!.average, 20);
    expect(peak.classification, FaixaQualidadeAr.moderada);
  });

  test('Rejeita médias com horários ausentes', () {
    final data = createForecast();

    final missingTime = reference.add(
      const Duration(hours: 4),
    );

    final incomplete = ForecastData(
      referenceTime: reference,
      hours: data.hours
          .where((hour) => hour.time != missingTime)
          .toList(),
    );

    final average = ForecastAnalysis.rollingAverage(
      incomplete,
      PoluenteBr.mp25,
      reference.add(const Duration(hours: 6)),
    );

    expect(average, isNull);
  });

  test('Resume os picos por dia', () {
    final data = createForecast();

    final points = ForecastAnalysis.calculate(
      data,
      PoluenteBr.ozonio,
      72,
    );

    final daily = ForecastAnalysis.dailyPeaks(points);

    expect(daily, isNotEmpty);
    expect(daily.every((point) => point.average == 80), isTrue);
  });

  test('Rejeita horizonte de previsão inválido', () {
    expect(
      () => ForecastAnalysis.calculate(
        createForecast(),
        PoluenteBr.mp25,
        0,
      ),
      throwsArgumentError,
    );
  });
}
