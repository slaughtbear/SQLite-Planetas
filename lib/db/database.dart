import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // Importa path_provider

import '../planetas/planetas.dart';

class DB {
  static Future<sqlite.Database> db() async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, "solarsystem.db");

    return sqlite.openDatabase(
      path,
      version: 1,
      singleInstance: true,
      onCreate: (db, version) async {
        await create(db);
      },
    );
  }

  static Future<void> create(sqlite.Database db) async {
    const String sql = """
      CREATE TABLE planeta (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nombre TEXT NOT NULL,
      distanciaSol REAL NOT NULL,
      radio REAL NOT NULL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """;
    await db.execute(sql);
  }

  static Future<List<Planetas>> getPlanets() async {
    final sqlite.Database db = await DB.db();
    final List<Map<String, dynamic>> query = await db.query("planeta");
    List<Planetas> planets = query.map((e) {
      return Planetas.deMapa(e);
    }).toList();
    return planets;
  }

  static Future<int> insertPlanet(Planetas planet) async {
    final sqlite.Database db = await DB.db();
    final int id = await db.insert(
      "planeta",
      planet.mapeador(),
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> updatePlanet(Planetas planet) async {
    final sqlite.Database db = await DB.db();
    final int id = await db.update(
      "planeta",
      planet.mapeador(),
      where: "id = ?",
      whereArgs: [planet.id],
    );
    return id;
  }

  static Future<void> deletePlanet(int id) async {
    final sqlite.Database db = await DB.db();
    await db.delete("planeta", where: "id = ?", whereArgs: [id]);
  }
}
