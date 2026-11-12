import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/cache_store.dart';

class CachedApiResult<T> {
  final T data;
  final bool fromCache;
  final bool cacheSaved;
  final DateTime savedAt;

  const CachedApiResult({
    required this.data,
    required this.fromCache,
    required this.cacheSaved,
    required this.savedAt,
  });
}

class CachedApiClient {
  final http.Client client;
  final CacheStore store;

  const CachedApiClient({required this.client, required this.store});

  Future<CachedApiResult<T>> fetch<T>({
    required String key,
    required Uri uri,
    required T Function(Map<String, dynamic>) parse,
  }) async {
    try {
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('Falha na API: HTTP ${response.statusCode}');
      }

      final payload = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Resposta JSON inválida.');
      }

      final data = parse(decoded);
      final savedAt = DateTime.now().toUtc();

      var cacheSaved = true;

      try {
        await store.write(key, payload, savedAt);
      } catch (_) {
        cacheSaved = false;
      }

      return CachedApiResult<T>(
        data: data,
        fromCache: false,
        cacheSaved: cacheSaved,
        savedAt: savedAt,
      );
    } catch (_) {
      final cached = await store.read(key);

      if (cached == null) {
        rethrow;
      }

      final decoded = jsonDecode(cached.payload);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Os dados armazenados são inválidos.');
      }

      final data = parse(decoded);

      return CachedApiResult<T>(
        data: data,
        fromCache: true,
        cacheSaved: true,
        savedAt: cached.savedAt,
      );
    }
  }
}
