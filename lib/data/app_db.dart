// lib/data/app_db.dart
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDb {
  static final AppDb _instance = AppDb._internal();
  factory AppDb() => _instance;
  AppDb._internal();

  static const _dbName = 'card_organizer.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE folders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            createdAt TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rank TEXT NOT NULL,
            suit TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            folderId INTEGER,
            FOREIGN KEY(folderId) REFERENCES folders(id) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  // --------- Folder DAO ----------
  Future<int> insertFolder(Folder f) async {
    final db = await database;
    return await db.insert(
      'folders',
      f.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Folder>> getFolders() async {
    final db = await database;
    final rows = await db.query('folders', orderBy: 'id ASC');
    return rows.map(Folder.fromMap).toList();
  }

  Future<Folder?> getFolderByName(String name) async {
    final db = await database;
    final rows = await db.query('folders', where: 'name=?', whereArgs: [name]);
    return rows.isEmpty ? null : Folder.fromMap(rows.first);
  }

  Future<int> updateFolder(Folder f) async {
    final db = await database;
    return await db.update(
      'folders',
      f.toMap(),
      where: 'id=?',
      whereArgs: [f.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    return await db.delete('folders', where: 'id=?', whereArgs: [id]);
  }

  // --------- Card DAO ----------
  Future<int> insertCard(CardItem c) async {
    final db = await database;
    return await db.insert(
      'cards',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CardItem>> getCards({
    int? folderId,
    String? suit,
    bool onlyUnassigned = false,
  }) async {
    final db = await database;
    String? where;
    List<Object?> args = [];
    if (folderId != null) {
      where = 'folderId=?';
      args.add(folderId);
    } else if (onlyUnassigned) {
      where = 'folderId IS NULL';
    }
    if (suit != null) {
      if (where == null) {
        where = 'suit=?';
      } else {
        where = '$where AND suit=?';
      }
      args.add(suit);
    }
    final rows = await db.query(
      'cards',
      where: where,
      whereArgs: args,
      orderBy: 'id ASC',
    );
    return rows.map(CardItem.fromMap).toList();
  }

  Future<int> updateCard(CardItem c) async {
    final db = await database;
    return await db.update(
      'cards',
      c.toMap(),
      where: 'id=?',
      whereArgs: [c.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return await db.delete('cards', where: 'id=?', whereArgs: [id]);
  }

  Future<int> countCardsInFolder(int folderId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM cards WHERE folderId=?',
      [folderId],
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<CardItem?> getFirstCardInFolder(int folderId) async {
    final db = await database;
    final rows = await db.query(
      'cards',
      where: 'folderId=?',
      whereArgs: [folderId],
      limit: 1,
    );
    return rows.isEmpty ? null : CardItem.fromMap(rows.first);
  }
}
