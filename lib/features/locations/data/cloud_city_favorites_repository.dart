import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'brazilian_city.dart';
import 'city_favorites_repository.dart';

class CloudCityFavoritesRepository implements CityFavoritesRepository {
  final FirebaseFirestore firestore;
  final String userId;

  const CloudCityFavoritesRepository({
    required this.firestore,
    required this.userId,
  });

  CollectionReference<Map<String, dynamic>> get _collection {
    return firestore.collection('users').doc(userId).collection('favorites');
  }

  @override
  Future<List<BrazilianCity>> getFavorites() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _collection.get().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      snapshot = await _collection.get(const GetOptions(source: Source.cache));
    }

    final cities = snapshot.docs.map((document) {
      return BrazilianCity.fromDatabase(
        Map<String, Object?>.from(document.data()),
      );
    }).toList();

    cities.sort((first, second) {
      final nameComparison = first.name.toLowerCase().compareTo(
        second.name.toLowerCase(),
      );

      if (nameComparison != 0) {
        return nameComparison;
      }

      return first.state.toLowerCase().compareTo(second.state.toLowerCase());
    });

    return cities;
  }

  @override
  Future<void> addFavorite(BrazilianCity city) async {
    final operation = _collection
        .doc(city.id.toString())
        .set(Map<String, dynamic>.from(city.toDatabase()));

    await _awaitOrQueue(operation);
  }

  @override
  Future<void> removeFavorite(int cityId) async {
    final operation = _collection.doc(cityId.toString()).delete();

    await _awaitOrQueue(operation);
  }

  Future<void> _awaitOrQueue(Future<void> operation) async {
    try {
      await operation.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      return;
    }
  }
}
