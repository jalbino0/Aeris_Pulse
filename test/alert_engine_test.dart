
import 'package:flutter_test/flutter_test.dart';

import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';
import 'package:aeris_pulse/features/alerts/domain/alert_engine.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_data.dart';

void main() {
  final reference = DateTime(2026, 11, 8, 12);

  test('Cenário demonstrativo produz alertas brasileiros', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final alerts = AlertEngine.generate(
      data,
      demonstration: true,
    );

    expect(alerts.length, 3);
    expect(alerts.every((alert) => alert.demonstration), isTrue);
    expect(alerts.every((alert) => alert.coverage == 1), isTrue);
  });

  test('MP2,5 gera alerta quando a média prevista é ruim', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final alerts = AlertEngine.generate(data);

    final alert = alerts.firstWhere(
      (item) => item.pollutant == PoluenteBr.mp25,
    );

    expect(alert.classification, FaixaQualidadeAr.ruim);
    expect(alert.priority, AlertPriority.elevada);
    expect(alert.peakAverage, 60);
    expect(alert.referenceHours, 24);
    expect(alert.variation, 48);
  });

  test('Ozônio utiliza média de oito horas', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final alerts = AlertEngine.generate(data);

    final alert = alerts.firstWhere(
      (item) => item.pollutant == PoluenteBr.ozonio,
    );

    expect(alert.referenceHours, 8);
    expect(alert.peakAverage, 140);
    expect(alert.classification, FaixaQualidadeAr.ruim);
  });

  test('Não cria alertas quando todas as faixas são boas', () {
    final hours = List.generate(96, (index) {
      return ForecastHour(
        time: reference.add(Duration(hours: index - 23)),
        pm25: 8,
        pm10: 20,
        ozone: 50,
      );
    });

    final data = ForecastData(
      referenceTime: reference,
      hours: hours,
    );

    final alerts = AlertEngine.generate(data);

    expect(alerts, isEmpty);
  });

  test('Não inventa alertas quando faltam dados futuros', () {
    final hours = List.generate(96, (index) {
      final offset = index - 23;

      return ForecastHour(
        time: reference.add(Duration(hours: offset)),
        pm25: offset > 0 ? null : 12,
        pm10: 20,
        ozone: 50,
      );
    });

    final data = ForecastData(
      referenceTime: reference,
      hours: hours,
    );

    final alerts = AlertEngine.generate(data);

    expect(
      alerts.any((alert) => alert.pollutant == PoluenteBr.mp25),
      isFalse,
    );
  });

  test('Alertas apresentam evidências e limitações', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    final alert = AlertEngine.generate(data).first;

    expect(alert.availablePoints, greaterThan(0));
    expect(alert.expectedPoints, 72);
    expect(alert.confidenceLevel, 'Limitada');
    expect(alert.limitations, isNotEmpty);
    expect(alert.peakTime.isAfter(reference), isTrue);
  });

  test('Rejeita horizonte de análise inválido', () {
    final data = DemonstrationForecast.create(
      referenceTime: reference,
    );

    expect(
      () => AlertEngine.generate(data, horizonHours: 0),
      throwsArgumentError,
    );
  });
}
