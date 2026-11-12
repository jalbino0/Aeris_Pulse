
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aeris_pulse/core/network/cached_api_client.dart';
import 'package:aeris_pulse/core/storage/cache_store.dart';
import 'package:aeris_pulse/features/air_quality/data/air_quality_history_service.dart';
import 'package:aeris_pulse/features/forecasts/data/forecast_service.dart';

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
  final reference = DateTime(2026, 11, 8, 12);

  Map<String, dynamic> createResponse() {
    final times = List.generate(120, (index) {
      final date = reference.add(
        Duration(hours: index - 23),
      );

      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');

      return '$year-$month-${day}T$hour:00';
    });

    return {
      'current': {
        'time': '2026-11-08T12:00',
      },
      'hourly': {
        'time': times,
        'pm2_5': List<double>.filled(times.length, 18),
        'pm10': List<double>.filled(times.length, 32),
        'ozone': List<double>.filled(times.length, 70),
      },
    };
  }

  test('Histórico é armazenado e recuperado offline', () async {
    final store = MemoryCacheStore();
    var offline = false;

    final httpClient = MockClient((request) async {
      if (offline) {
        throw Exception('Sem conexão');
      }

      return http.Response(
        jsonEncode(createResponse()),
        200,
      );
    });

    final service = AirQualityHistoryService(
      CachedApiClient(
        client: httpClient,
        store: store,
      ),
    );

    final online = await service.fetchSaoPauloHistory();

    expect(online.fromCache, isFalse);
    expect(online.cacheSaved, isTrue);
    expect(online.data.hours.length, 24);

    offline = true;

    final cached = await service.fetchSaoPauloHistory();

    expect(cached.fromCache, isTrue);
    expect(cached.data.hours.length, 24);
    expect(cached.data.hours.last.pm25, 18);

    httpClient.close();
  });

  test('Previsões são armazenadas e recuperadas offline', () async {
    final store = MemoryCacheStore();
    var offline = false;

    final httpClient = MockClient((request) async {
      if (offline) {
        throw Exception('Sem conexão');
      }

      return http.Response(
        jsonEncode(createResponse()),
        200,
      );
    });

    final service = ForecastService(
      CachedApiClient(
        client: httpClient,
        store: store,
      ),
    );

    final online = await service.fetchForecast();

    expect(online.fromCache, isFalse);
    expect(online.cacheSaved, isTrue);
    expect(online.data.hours.length, 120);

    offline = true;

    final cached = await service.fetchForecast();

    expect(cached.fromCache, isTrue);
    expect(cached.data.hours.length, 120);
    expect(cached.data.hours.first.pm10, 32);

    httpClient.close();
  });
}
