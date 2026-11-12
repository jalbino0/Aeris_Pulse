
import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_history.dart';
import 'package:aeris_pulse/features/air_quality/domain/air_quality_analysis.dart';

void main() {
  final reference = DateTime(2026, 11, 7, 23);

  AirQualityHistory createHistory() {
    final samples = List.generate(24, (index) {
      return AirQualityHour(
        time: reference.subtract(
          Duration(hours: 23 - index),
        ),
        pm25: 15,
        pm10: 48,
        ozone: 120,
      );
    });

    return AirQualityHistory(
      referenceTime: reference,
      hours: samples,
    );
  }

  test('Calcula média de 24 horas para MP2,5', () {
    final history = createHistory();

    final average = AirQualityAnalysis.referenceAverage(
      history,
      PoluenteBr.mp25,
    );

    expect(average, 15);

    expect(
      AirQualityAnalysis.referenceClassification(
        history,
        PoluenteBr.mp25,
      ),
      FaixaQualidadeAr.boa,
    );
  });

  test('Calcula média de 24 horas para MP10', () {
    final history = createHistory();

    expect(
      AirQualityAnalysis.referenceAverage(
        history,
        PoluenteBr.mp10,
      ),
      48,
    );

    expect(
      AirQualityAnalysis.referenceClassification(
        history,
        PoluenteBr.mp10,
      ),
      FaixaQualidadeAr.moderada,
    );
  });

  test('Calcula média de 8 horas para ozônio', () {
    final history = createHistory();

    expect(
      AirQualityAnalysis.referenceAverage(
        history,
        PoluenteBr.ozonio,
      ),
      120,
    );

    expect(
      AirQualityAnalysis.referenceClassification(
        history,
        PoluenteBr.ozonio,
      ),
      FaixaQualidadeAr.moderada,
    );
  });

  test('Rejeita histórico com horário ausente', () {
    final history = createHistory();

    final incomplete = AirQualityHistory(
      referenceTime: reference,
      hours: history.hours.sublist(1),
    );

    expect(
      AirQualityAnalysis.referenceAverage(
        incomplete,
        PoluenteBr.mp25,
      ),
      isNull,
    );
  });

  test('Rejeita concentrações incompletas', () {
    final history = createHistory();

    final incomplete = AirQualityHistory(
      referenceTime: reference,
      hours: [
        ...history.hours.sublist(0, 23),
        AirQualityHour(
          time: reference,
          pm25: null,
          pm10: 48,
          ozone: 120,
        ),
      ],
    );

    expect(
      AirQualityAnalysis.referenceAverage(
        incomplete,
        PoluenteBr.mp25,
      ),
      isNull,
    );
  });
}
