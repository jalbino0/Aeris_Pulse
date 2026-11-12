import 'package:sqflite/sqflite.dart';

import '../../../core/storage/cache_store.dart';
import 'brazilian_city.dart';

abstract class SelectedCityRepository {
  Future<BrazilianCity> getSelected();

  Future<void> save(BrazilianCity city);
}

class SqliteSelectedCityRepository implements SelectedCityRepository {
  final SqliteCacheStore store;

  const SqliteSelectedCityRepository(this.store);

  static const BrazilianCity defaultCity = BrazilianCity(
    id: 0,
    name: 'São Paulo',
    state: 'São Paulo',
    latitude: -23.5505,
    longitude: -46.6333,
    timezone: 'America/Sao_Paulo',
  );

  @override
  Future<BrazilianCity> getSelected() async {
    final db = await store.database;

    final rows = await db.query(
      'selected_city',
      where: 'selection_id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return defaultCity;
    }

    final row = rows.first;

    return BrazilianCity(
      id: row['city_id'] as int,
      name: row['name'] as String,
      state: row['state'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      timezone: row['timezone'] as String,
    );
  }

  @override
  Future<void> save(BrazilianCity city) async {
    final db = await store.database;

    await db.insert('selected_city', {
      'selection_id': 1,
      'city_id': city.id,
      'name': city.name,
      'state': city.state,
      'latitude': city.latitude,
      'longitude': city.longitude,
      'timezone': city.timezone,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
