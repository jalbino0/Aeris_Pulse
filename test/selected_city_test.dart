
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aeris_pulse/features/auth/providers/auth_user_provider.dart';
import 'package:aeris_pulse/features/locations/data/brazilian_city.dart';
import 'package:aeris_pulse/features/locations/data/selected_city_repository.dart';
import 'package:aeris_pulse/features/locations/providers/selected_city_provider.dart';

class MemorySelectedCityRepository
    implements SelectedCityRepository {
  BrazilianCity selected =
      SqliteSelectedCityRepository.defaultCity;

  int saveCount = 0;

  @override
  Future<BrazilianCity> getSelected() async {
    return selected;
  }

  @override
  Future<void> save(BrazilianCity city) async {
    selected = city;
    saveCount++;
  }
}

ProviderContainer createTestContainer(
  MemorySelectedCityRepository repository,
) {
  return ProviderContainer(
    overrides: [
      authUserIdProvider.overrideWithValue(
        const AsyncData<String?>(null),
      ),
      selectedCityRepositoryProvider.overrideWith(
        (ref) => repository,
      ),
    ],
  );
}

void main() {
  const campinas = BrazilianCity(
    id: 1001,
    name: 'Campinas',
    state: 'São Paulo',
    latitude: -22.9056,
    longitude: -47.0608,
    timezone: 'America/Sao_Paulo',
  );

  test('Inicia o monitoramento com São Paulo', () async {
    final repository = MemorySelectedCityRepository();
    final container = createTestContainer(repository);

    addTearDown(container.dispose);

    final city = await container.read(
      selectedCityProvider.future,
    );

    expect(city.name, 'São Paulo');
    expect(city.latitude, -23.5505);
    expect(repository.saveCount, 0);
  });

  test('Permite selecionar uma nova cidade', () async {
    final repository = MemorySelectedCityRepository();
    final container = createTestContainer(repository);

    addTearDown(container.dispose);

    await container.read(selectedCityProvider.future);

    await container
        .read(selectedCityProvider.notifier)
        .select(campinas);

    final selected = container.read(
      selectedCityProvider,
    ).asData?.value;

    expect(selected, isNotNull);
    expect(selected!.id, 1001);
    expect(selected.name, 'Campinas');
    expect(repository.saveCount, 1);
    expect(repository.selected.latitude, -22.9056);
  });

  test('Recupera a seleção ao recriar o provider', () async {
    final repository = MemorySelectedCityRepository();

    final firstContainer = createTestContainer(repository);

    await firstContainer.read(
      selectedCityProvider.future,
    );

    await firstContainer
        .read(selectedCityProvider.notifier)
        .select(campinas);

    firstContainer.dispose();

    final secondContainer = createTestContainer(repository);

    addTearDown(secondContainer.dispose);

    final restored = await secondContainer.read(
      selectedCityProvider.future,
    );

    expect(restored.id, campinas.id);
    expect(restored.name, campinas.name);
    expect(restored.longitude, campinas.longitude);
  });

  test('Visitante utiliza o repositório local', () async {
    final repository = MemorySelectedCityRepository();
    final container = createTestContainer(repository);

    addTearDown(container.dispose);

    final userId = await container.read(
      authUserIdProvider.future,
    );

    expect(userId, isNull);

    await container.read(selectedCityProvider.future);

    await container
        .read(selectedCityProvider.notifier)
        .select(campinas);

    expect(repository.selected.id, campinas.id);
    expect(repository.saveCount, 1);
  });
}
