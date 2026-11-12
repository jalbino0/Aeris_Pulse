import 'package:sqflite/sqflite.dart';

import '../../../core/storage/cache_store.dart';
import 'brazilian_city.dart';

abstract class CityFavoritesRepository {
  Future<List<BrazilianCity>> getFavorites();

  Future<void> addFavorite(BrazilianCity city);

  Future<void> removeFavorite(int cityId);
}

class SqliteCityFavoritesRepository implements CityFavoritesRepository {
  final SqliteCacheStore store;

  const SqliteCityFavoritesRepository(this.store);

  @override
  Future<List<BrazilianCity>> getFavorites() async {
    final db = await store.database;

    final rows = await db.query(
      'favorite_cities',
      orderBy: 'name COLLATE NOCASE ASC, state ASC',
    );

    return rows.map(BrazilianCity.fromDatabase).toList(growable: false);
  }

  @override
  Future<void> addFavorite(BrazilianCity city) async {
    final db = await store.database;

    await db.insert(
      'favorite_cities',
      city.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavorite(int cityId) async {
    final db = await store.database;

    await db.delete('favorite_cities', where: 'id = ?', whereArgs: [cityId]);
  }
}
