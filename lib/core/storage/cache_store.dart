import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CacheRecord {
  final String payload;
  final DateTime savedAt;

  const CacheRecord({required this.payload, required this.savedAt});
}

abstract class CacheStore {
  Future<CacheRecord?> read(String key);

  Future<void> write(String key, String payload, DateTime savedAt);
}

class SqliteCacheStore implements CacheStore {
  Future<Database>? _databaseFuture;

  Future<Database> get database {
    return _databaseFuture ??= _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final directory = await getDatabasesPath();
    final databasePath = join(directory, 'aeris_pulse.db');

    return openDatabase(
      databasePath,
      version: 3,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE api_cache ('
          'cache_key TEXT PRIMARY KEY, '
          'payload TEXT NOT NULL, '
          'saved_at INTEGER NOT NULL'
          ')',
        );

        await _createFavoriteCitiesTable(database);
        await _createSelectedCityTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createFavoriteCitiesTable(database);
        }

        if (oldVersion < 3) {
          await _createSelectedCityTable(database);
        }
      },
    );
  }

  Future<void> _createFavoriteCitiesTable(DatabaseExecutor database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS favorite_cities ('
      'id INTEGER PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'state TEXT NOT NULL, '
      'latitude REAL NOT NULL, '
      'longitude REAL NOT NULL, '
      'timezone TEXT NOT NULL'
      ')',
    );
  }

  Future<void> _createSelectedCityTable(DatabaseExecutor database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS selected_city ('
      'selection_id INTEGER PRIMARY KEY '
      'CHECK (selection_id = 1), '
      'city_id INTEGER NOT NULL, '
      'name TEXT NOT NULL, '
      'state TEXT NOT NULL, '
      'latitude REAL NOT NULL, '
      'longitude REAL NOT NULL, '
      'timezone TEXT NOT NULL'
      ')',
    );
  }

  @override
  Future<CacheRecord?> read(String key) async {
    final db = await database;

    final rows = await db.query(
      'api_cache',
      columns: ['payload', 'saved_at'],
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    return CacheRecord(
      payload: row['payload'] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        row['saved_at'] as int,
        isUtc: true,
      ),
    );
  }

  @override
  Future<void> write(String key, String payload, DateTime savedAt) async {
    final db = await database;

    await db.insert('api_cache', {
      'cache_key': key,
      'payload': payload,
      'saved_at': savedAt.toUtc().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
