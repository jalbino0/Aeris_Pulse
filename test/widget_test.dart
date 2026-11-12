import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:aeris_pulse/core/theme/app_theme.dart';
import 'package:aeris_pulse/features/home/home_screen.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_reading.dart';
import 'package:aeris_pulse/features/air_quality/providers/air_quality_provider.dart';
import 'package:aeris_pulse/features/locations/data/brazilian_city.dart';
import 'package:aeris_pulse/features/locations/data/selected_city_repository.dart';
import 'package:aeris_pulse/features/locations/providers/selected_city_provider.dart';

class FakeSelectedCityRepository implements SelectedCityRepository {
  BrazilianCity city;

  FakeSelectedCityRepository(this.city);

  @override
  Future<BrazilianCity> getSelected() async {
    return city;
  }

  @override
  Future<void> save(BrazilianCity selectedCity) async {
    city = selectedCity;
  }
}

Future<void> pumpHome(
  WidgetTester tester,
  BrazilianCity city, {
  required double pm25,
  required double pm10,
  required double ozone,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCityRepositoryProvider.overrideWith(
          (ref) => FakeSelectedCityRepository(city),
        ),
        airQualityProvider.overrideWith((ref) async {
          return AirQualityReading(
            location: '${city.name} (${city.state})',
            referenceTime: '2026-11-08T12:00',
            pm25: pm25,
            pm10: pm10,
            ozone: ozone,
          );
        }),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void expectRefreshButton() {
  final finder = find.byWidgetPredicate((widget) {
    if (widget is! IconButton) {
      return false;
    }

    final tooltip = widget.tooltip?.toLowerCase() ?? '';

    return tooltip.contains('atualizar');
  });

  expect(finder, findsOneWidget);
}

Future<void> expectTextAfterScroll(WidgetTester tester, String text) async {
  final finder = find.text(text);

  await tester.scrollUntilVisible(
    finder,
    180,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.pump();

  expect(finder, findsOneWidget);
}

void main() {
  testWidgets('Aeris Pulse apresenta dados ambientais de São Paulo', (
    tester,
  ) async {
    const city = SqliteSelectedCityRepository.defaultCity;

    await pumpHome(tester, city, pm25: 12.5, pm10: 25.0, ozone: 65.0);

    expect(find.text('Aeris Pulse'), findsOneWidget);
    expect(find.text('Seu ar, agora'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('São Paulo • Brasil'), findsOneWidget);

    expectRefreshButton();

    await expectTextAfterScroll(tester, 'MP2,5');
    await expectTextAfterScroll(tester, '12,5');

    await expectTextAfterScroll(tester, 'MP10');
    await expectTextAfterScroll(tester, '25,0');

    await expectTextAfterScroll(tester, 'Ozônio');
    await expectTextAfterScroll(tester, '65,0');
  });

  testWidgets('Aeris Pulse apresenta dados ambientais de Recife', (
    tester,
  ) async {
    const city = BrazilianCity(
      id: 1002,
      name: 'Recife',
      state: 'Pernambuco',
      latitude: -8.0539,
      longitude: -34.8811,
      timezone: 'America/Recife',
    );

    await pumpHome(tester, city, pm25: 18.5, pm10: 31.0, ozone: 72.0);

    expect(find.text('Aeris Pulse'), findsOneWidget);
    expect(find.text('Seu ar, agora'), findsOneWidget);
    expect(find.text('Recife'), findsOneWidget);
    expect(find.text('Pernambuco • Brasil'), findsOneWidget);

    expect(find.text('São Paulo'), findsNothing);

    expectRefreshButton();

    await expectTextAfterScroll(tester, 'MP2,5');
    await expectTextAfterScroll(tester, '18,5');

    await expectTextAfterScroll(tester, 'MP10');
    await expectTextAfterScroll(tester, '31,0');

    await expectTextAfterScroll(tester, 'Ozônio');
    await expectTextAfterScroll(tester, '72,0');
  });
}
