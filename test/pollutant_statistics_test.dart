
import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_history.dart';
import 'package:aeris_pulse/features/air_quality/domain/pollutant_statistics.dart';

void main() {
  final reference = DateTime(2026, 11, 7, 23);

  AirQualityHistory sampleHistory() {
    final hours = List.generate(24, (index) {
      return AirQualityHour(
        time: reference.subtract(Duration(hours: 23 - index)),
        pm25: index == 23 ? 24 : index == 22 ? 20 : 12,
        pm10: 40,
        ozone: 70,
      );
    });

    return AirQualityHistory(
      referenceTime: reference,
      hours: hours,
    );
  }

  test('Mostra concentração de referência e mudança horária', () {
    final statistics = PollutantStatistics.fromHistory(
      sampleHistory(),
      PoluenteBr.mp25,
    );

    expect(statistics.latest, 24);
    expect(statistics.previous, 20);
    expect(statistics.hourlyChange, 4);
  });

  test('Resume mínimo e máximo sem comparar poluentes distintos', () {
    final statistics = PollutantStatistics.fromHistory(
      sampleHistory(),
      PoluenteBr.mp25,
    );

    expect(statistics.minimum, 12);
    expect(statistics.maximum, 24);
    expect(statistics.validSamples, 24);
  });

  test('Retorna classificação brasileira com média completa', () {
    final statistics = PollutantStatistics.fromHistory(
      sampleHistory(),
      PoluenteBr.mp10,
    );

    expect(statistics.referenceAverage, 40);
    expect(statistics.classification, FaixaQualidadeAr.boa);
  });

  test('Não calcula variação quando falta hora anterior', () {
    final full = sampleHistory();

    final incomplete = AirQualityHistory(
      referenceTime: reference,
      hours: [
        ...full.hours.sublist(0, 22),
        full.hours.last,
      ],
    );

    final statistics = PollutantStatistics.fromHistory(
      incomplete,
      PoluenteBr.mp25,
    );

    expect(statistics.latest, 24);
    expect(statistics.previous, isNull);
    expect(statistics.hourlyChange, isNull);
    expect(statistics.referenceAverage, isNull);
    expect(statistics.classification, isNull);
  });

  test('Dados ausentes na hora de referência não são inventados', () {
    final full = sampleHistory();

    final incomplete = AirQualityHistory(
      referenceTime: reference,
      hours: full.hours.sublist(0, 23),
    );

    final statistics = PollutantStatistics.fromHistory(
      incomplete,
      PoluenteBr.mp25,
    );

    expect(statistics.latest, isNull);
    expect(statistics.hourlyChange, isNull);
    expect(statistics.referenceAverage, isNull);
  });
}
