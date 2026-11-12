import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aeris_pulse/core/network/cached_api_client.dart';
import 'package:aeris_pulse/core/network/environment_cache_keys.dart';
import 'package:aeris_pulse/core/storage/cache_store.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_service.dart';
import 'package:aeris_pulse/features/locations/data/brazilian_city.dart';
import 'package:aeris_pulse/features/locations/data/selected_city_repository.dart';

class MemoryCacheStore implements CacheStore {
  final Map<String, CacheRecord> records = {};

  @override
  Future<CacheRecord?> read(String key) async {
    return records[key];
  }

  @override
  Future<void> write(String key, String payload, DateTime savedAt) async {
    records[key] = CacheRecord(payload: payload, savedAt: savedAt);
  }
}

void main() {
  const saoPaulo = SqliteSelectedCityRepository.defaultCity;

  const recife = BrazilianCity(
    id: 1002,
    name: 'Recife',
    state: 'Pernambuco',
    latitude: -8.0539,
    longitude: -34.8811,
    timezone: 'America/Recife',
  );

  test('Cada cidade possui uma chave de cache diferente', () {
    expect(
      EnvironmentCacheKeys.api(saoPaulo, 'home'),
      'air_quality_current_sao_paulo',
    );

    expect(
      EnvironmentCacheKeys.api(saoPaulo, 'home'),
      isNot(EnvironmentCacheKeys.api(recife, 'home')),
    );

    expect(
      EnvironmentCacheKeys.api(recife, 'history'),
      isNot(EnvironmentCacheKeys.api(recife, 'forecast')),
    );

    expect(
      EnvironmentCacheKeys.status(saoPaulo, 'home'),
      isNot(EnvironmentCacheKeys.status(recife, 'home')),
    );
  });

  test('Consulta as coordenadas e o fuso da cidade selecionada', () async {
    final requestedCoordinates = <String>[];
    final requestedTimezones = <String, String?>{};

    final client = MockClient((request) async {
      final latitude = request.url.queryParameters['latitude'];
      final longitude = request.url.queryParameters['longitude'];
      final timezone = request.url.queryParameters['timezone'];

      final coordinates = '$latitude,$longitude';

      requestedCoordinates.add(coordinates);
      requestedTimezones[coordinates] = timezone;

      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'current': {
              'time': '2026-11-08T12:00',
              'pm2_5': 20,
              'pm10': 35,
              'ozone': 60,
            },
          }),
        ),
        200,
      );
    });

    final service = AirQualityService(
      CachedApiClient(client: client, store: MemoryCacheStore()),
    );

    final first = await service.fetchCity(saoPaulo);
    final second = await service.fetchCity(recife);

    expect(first.data.location, 'São Paulo (São Paulo)');

    expect(second.data.location, 'Recife (Pernambuco)');

    final saoPauloCoordinates = '${saoPaulo.latitude},${saoPaulo.longitude}';

    final recifeCoordinates = '${recife.latitude},${recife.longitude}';

    expect(requestedCoordinates, contains(saoPauloCoordinates));

    expect(requestedCoordinates, contains(recifeCoordinates));

    expect(requestedTimezones[saoPauloCoordinates], saoPaulo.timezone);

    expect(requestedTimezones[recifeCoordinates], recife.timezone);

    expect(requestedCoordinates.length, 2);

    client.close();
  });

  test('Recupera o cache correto para cada cidade', () async {
    final store = MemoryCacheStore();
    var offline = false;

    final client = MockClient((request) async {
      if (offline) {
        throw Exception('Conexão indisponível');
      }

      final latitude = double.parse(request.url.queryParameters['latitude']!);

      final pm25 = latitude < -15 ? 12.0 : 28.0;

      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'current': {
              'time': '2026-11-08T12:00',
              'pm2_5': pm25,
              'pm10': 35.0,
              'ozone': 60.0,
            },
          }),
        ),
        200,
      );
    });

    final service = AirQualityService(
      CachedApiClient(client: client, store: store),
    );

    final saoPauloOnline = await service.fetchCity(saoPaulo);
    final recifeOnline = await service.fetchCity(recife);

    expect(saoPauloOnline.data.pm25, 12);
    expect(recifeOnline.data.pm25, 28);

    expect(saoPauloOnline.fromCache, isFalse);
    expect(recifeOnline.fromCache, isFalse);

    offline = true;

    final saoPauloOffline = await service.fetchCity(saoPaulo);
    final recifeOffline = await service.fetchCity(recife);

    expect(saoPauloOffline.fromCache, isTrue);
    expect(recifeOffline.fromCache, isTrue);

    expect(saoPauloOffline.data.pm25, 12);
    expect(recifeOffline.data.pm25, 28);

    expect(saoPauloOffline.data.location, 'São Paulo (São Paulo)');

    expect(recifeOffline.data.location, 'Recife (Pernambuco)');

    expect(store.records.length, 2);

    client.close();
  });
}
