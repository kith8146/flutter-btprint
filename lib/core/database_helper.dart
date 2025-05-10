import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/print_record.dart';
import 'error_utils.dart'; // ✅ 예외 로깅 함수 사용

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
    try {
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
    } catch (e, stack) {
      logError('DatabaseHelper._initDb', e, stack);
      rethrow;
    }
  }

  /// 삽입 후 생성된 id 반환
  Future<int> insertRecord(PrintRecord record) async {
    try {
      final db = await database;
      return await db.insert(
        'records',
        {
          'timestamp': record.timestamp.toIso8601String(),
          'contentText': record.contentText,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      logError('DatabaseHelper.insertRecord', e, stack);
      return -1;
    }
  }

  Future<List<PrintRecord>> getAllRecords() async {
    try {
      final db = await database;
      final rows = await db.query('records', orderBy: 'id DESC');
      return rows.map((r) => PrintRecord(
        id: r['id'] as int,
        timestamp: DateTime.parse(r['timestamp'] as String),
        contentText: r['contentText'] as String,
      )).toList();
    } catch (e, stack) {
      logError('DatabaseHelper.getAllRecords', e, stack);
      return [];
    }
  }

  Future<void> deleteById(int id) async {
    try {
      final db = await database;
      await db.delete('records', where: 'id = ?', whereArgs: [id]);
    } catch (e, stack) {
      logError('DatabaseHelper.deleteById', e, stack);
    }
  }

  Future<void> deleteAllRecords() async {
    try {
      final db = await database;
      await db.delete('records');
    } catch (e, stack) {
      logError('DatabaseHelper.deleteAllRecords', e, stack);
    }
  }
}
