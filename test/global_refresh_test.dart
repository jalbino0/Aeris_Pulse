
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aeris_pulse/core/providers/global_refresh_provider.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_history.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_reading.dart';
import 'package:aeris_pulse/features/air_quality/providers/air_quality_history_provider.dart';
import 'package:aeris_pulse/features/air_quality/providers/air_quality_provider.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_data.dart';
import 'package:aeris_pulse/features/forecasts/providers/forecast_provider.dart';

void main() {
  test('Atualização global consulta os três providers', () async {
    var homeCalls = 0;
    var historyCalls = 0;
    var forecastCalls = 0;

    final reference = DateTime(2026, 11, 8, 12);

    final container = ProviderContainer(
      overrides: [
        airQualityProvider.overrideWith((ref) async {
          homeCalls++;

          return const AirQualityReading(
            location: 'São Paulo (SP)',
            referenceTime: '2026-11-08T12:00',
            pm25: 12,
            pm10: 20,
            ozone: 50,
          );
        }),
        airQualityHistoryProvider.overrideWith((ref) async {
          historyCalls++;

          return AirQualityHistory(
            referenceTime: reference,
            hours: const [],
          );
        }),
        forecastProvider.overrideWith((ref) async {
          forecastCalls++;

          return ForecastData(
            referenceTime: reference,
            hours: const [],
          );
        }),
      ],
    );

    addTearDown(container.dispose);

    await Future.wait([
      container.read(airQualityProvider.future),
      container.read(airQualityHistoryProvider.future),
      container.read(forecastProvider.future),
    ]);

    expect(homeCalls, 1);
    expect(historyCalls, 1);
    expect(forecastCalls, 1);

    final result = await container
        .read(globalRefreshProvider.notifier)
        .refreshAll();

    expect(result.successful, 3);
    expect(result.failed, 0);

    expect(homeCalls, 2);
    expect(historyCalls, 2);
    expect(forecastCalls, 2);

    expect(
      container.read(globalRefreshProvider),
      isFalse,
    );
  });
}
