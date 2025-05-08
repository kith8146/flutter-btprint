// lib/core/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/print_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, "print_records.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            contentText TEXT
          )
        ''');
      },
    );
  }

  /// 삽입 후 생성된 id를 반환하도록!
  Future<int> insertRecord(PrintRecord record) async {
    final db = await database;
    return await db.insert(
      'records',
      {
        'timestamp': record.timestamp.toIso8601String(),
        'contentText': record.contentText,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PrintRecord>> getAllRecords() async {
    final db = await database;
    final rows = await db.query('records', orderBy: 'id DESC');
    return rows.map((r) => PrintRecord(
      id: r['id'] as int,
      timestamp: DateTime.parse(r['timestamp'] as String),
      contentText: r['contentText'] as String,
    )).toList();
  }

  Future<void> deleteById(int id) async {
    final db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete('records');
  }
}
