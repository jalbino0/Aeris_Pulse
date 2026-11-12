import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/providers/cache_provider.dart';
import '../../auth/providers/auth_user_provider.dart';
import '../data/brazilian_city.dart';
import '../data/city_favorites_repository.dart';
import '../data/city_search_service.dart';
import '../data/cloud_city_favorites_repository.dart';

final citySearchServiceProvider = Provider<CitySearchService>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return CitySearchService(client);
});

final citySearchProvider = FutureProvider.family<List<BrazilianCity>, String>((
  ref,
  query,
) {
  return ref.watch(citySearchServiceProvider).search(query);
});

final cityFavoritesRepositoryProvider = Provider<CityFavoritesRepository>((
  ref,
) {
  final userId = ref.watch(authUserIdProvider).asData?.value;

  if (userId != null) {
    return CloudCityFavoritesRepository(
      firestore: FirebaseFirestore.instance,
      userId: userId,
    );
  }

  return SqliteCityFavoritesRepository(ref.watch(sqliteStoreProvider));
});

final favoriteCitiesProvider = FutureProvider<List<BrazilianCity>>((ref) async {
  final authState = ref.watch(authUserIdProvider);

  if (!authState.hasValue) {
    await ref.watch(authUserIdProvider.future);
  }

  if (!ref.mounted) {
    throw StateError('Provider indisponível.');
  }

  return ref.read(cityFavoritesRepositoryProvider).getFavorites();
});
