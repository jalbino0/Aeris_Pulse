import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../network/cached_api_client.dart';
import '../storage/cache_store.dart';

class ResourceCacheStatus {
  final bool fromCache;
  final bool cacheSaved;
  final DateTime savedAt;

  const ResourceCacheStatus({
    required this.fromCache,
    required this.cacheSaved,
    required this.savedAt,
  });
}

class CacheStatusNotifier extends Notifier<Map<String, ResourceCacheStatus>> {
  @override
  Map<String, ResourceCacheStatus> build() {
    return {};
  }

  void register<T>(String key, CachedApiResult<T> result) {
    state = {
      ...state,
      key: ResourceCacheStatus(
        fromCache: result.fromCache,
        cacheSaved: result.cacheSaved,
        savedAt: result.savedAt,
      ),
    };
  }
}

final cacheStatusProvider =
    NotifierProvider<CacheStatusNotifier, Map<String, ResourceCacheStatus>>(
      CacheStatusNotifier.new,
    );

final sqliteStoreProvider = Provider<SqliteCacheStore>((ref) {
  return SqliteCacheStore();
});

final cacheStoreProvider = Provider<CacheStore>((ref) {
  return ref.watch(sqliteStoreProvider);
});

final cachedApiClientProvider = Provider<CachedApiClient>((ref) {
  final httpClient = http.Client();

  ref.onDispose(httpClient.close);

  return CachedApiClient(
    client: httpClient,
    store: ref.watch(cacheStoreProvider),
  );
});
