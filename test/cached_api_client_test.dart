
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aeris_pulse/core/network/cached_api_client.dart';
import 'package:aeris_pulse/core/storage/cache_store.dart';

class MemoryCacheStore implements CacheStore {
  final Map<String, CacheRecord> records = {};

  @override
  Future<CacheRecord?> read(String key) async {
    return records[key];
  }

  @override
  Future<void> write(
    String key,
    String payload,
    DateTime savedAt,
  ) async {
    records[key] = CacheRecord(
      payload: payload,
      savedAt: savedAt,
    );
  }
}

void main() {
  final uri = Uri.https('example.com', '/environment');

  int parseReading(Map<String, dynamic> json) {
    final value = json['pm25'];

    if (value is! num) {
      throw const FormatException('Concentração inválida.');
    }

    return value.toInt();
  }

  test('Salva uma resposta válida no armazenamento', () async {
    final store = MemoryCacheStore();

    final client = CachedApiClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'pm25': 18}),
          200,
        );
      }),
      store: store,
    );

    final result = await client.fetch<int>(
      key: 'test_current',
      uri: uri,
      parse: parseReading,
    );

    expect(result.data, 18);
    expect(result.fromCache, isFalse);
    expect(result.cacheSaved, isTrue);

    final saved = await store.read('test_current');

    expect(saved, isNotNull);
    expect(jsonDecode(saved!.payload)['pm25'], 18);
  });

  test('Recupera dados salvos quando a API falha', () async {
    final store = MemoryCacheStore();

    await store.write(
      'test_current',
      jsonEncode({'pm25': 23}),
      DateTime.utc(2026, 11, 8, 12),
    );

    final client = CachedApiClient(
      client: MockClient((request) async {
        throw Exception('Conexão indisponível');
      }),
      store: store,
    );

    final result = await client.fetch<int>(
      key: 'test_current',
      uri: uri,
      parse: parseReading,
    );

    expect(result.data, 23);
    expect(result.fromCache, isTrue);
    expect(result.cacheSaved, isTrue);
    expect(result.savedAt, DateTime.utc(2026, 11, 8, 12));
  });

  test('Não inventa dados quando a API e o cache falham', () async {
    final store = MemoryCacheStore();

    final client = CachedApiClient(
      client: MockClient((request) async {
        throw Exception('Conexão indisponível');
      }),
      store: store,
    );

    await expectLater(
      client.fetch<int>(
        key: 'missing_data',
        uri: uri,
        parse: parseReading,
      ),
      throwsException,
    );
  });

  test('Não substitui dados válidos por resposta inválida', () async {
    final store = MemoryCacheStore();

    await store.write(
      'test_current',
      jsonEncode({'pm25': 15}),
      DateTime.utc(2026, 11, 8, 10),
    );

    final client = CachedApiClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'pm25': null}),
          200,
        );
      }),
      store: store,
    );

    final result = await client.fetch<int>(
      key: 'test_current',
      uri: uri,
      parse: parseReading,
    );

    expect(result.data, 15);
    expect(result.fromCache, isTrue);

    final saved = await store.read('test_current');

    expect(jsonDecode(saved!.payload)['pm25'], 15);
  });

  test('Uma nova resposta atualiza a cópia anterior', () async {
    final store = MemoryCacheStore();

    await store.write(
      'test_current',
      jsonEncode({'pm25': 10}),
      DateTime.utc(2026, 11, 8, 9),
    );

    final client = CachedApiClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'pm25': 21}),
          200,
        );
      }),
      store: store,
    );

    final result = await client.fetch<int>(
      key: 'test_current',
      uri: uri,
      parse: parseReading,
    );

    expect(result.data, 21);
    expect(result.fromCache, isFalse);

    final saved = await store.read('test_current');

    expect(jsonDecode(saved!.payload)['pm25'], 21);
  });
}
