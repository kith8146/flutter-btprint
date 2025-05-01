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
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "print_records.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
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

  Future<void> insertRecord(PrintRecord record) async {
    final db = await database;
    await db.insert(
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
    final maps = await db.query('records', orderBy: 'id DESC');

    return maps.map((map) {
      return PrintRecord(
        timestamp: DateTime.parse(map['timestamp'] as String),
        contentText: map['contentText'] as String,
      );
    }).toList();
  }

  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete('records');
  }
}
