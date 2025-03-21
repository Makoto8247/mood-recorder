import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mood_recorder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood INTEGER NOT NULL,
        category TEXT NOT NULL,
        diary TEXT
      )
    ''');

    // カテゴリのデフォルト値を保存するテーブル
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // デフォルトカテゴリの追加
    await db.insert('categories', {'name': '元気'});
    await db.insert('categories', {'name': 'だるい'});
  }

  // 気分記録の追加
  Future<int> insertMoodRecord(MoodRecord record) async {
    final db = await database;
    return await db.insert('mood_records', record.toMap());
  }

  // 気分記録の取得（最新8日分、1日1記録）
  Future<List<MoodRecord>> getAllMoodRecords() async {
    final db = await database;
    final date = DateTime.now().subtract(const Duration(days: 7)); // 8日前から

    // サブクエリを使用して各日付の最新レコードのIDを取得
    final result = await db.rawQuery('''
      SELECT *
      FROM mood_records m1
      WHERE date >= ?
      AND NOT EXISTS (
        SELECT 1
        FROM mood_records m2
        WHERE date(m1.date) = date(m2.date)
        AND m2.id > m1.id
      )
      ORDER BY date ASC
    ''', [date.toIso8601String()]);

    return result.map((map) => MoodRecord.fromMap(map)).toList();
  }

  // カテゴリの取得
  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  // カテゴリの追加
  Future<int> insertCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {'name': name});
  }

  // カテゴリの削除
  Future<int> deleteCategory(String name) async {
    final db = await database;
    return await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  // 特定の日付範囲の記録を取得（編集用）
  Future<List<MoodRecord>> getMoodRecordsForEdit() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_records',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MoodRecord.fromMap(maps[i]));
  }

  // 記録の更新
  Future<int> updateMoodRecord(MoodRecord record) async {
    final db = await database;
    return await db.update(
      'mood_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // 記録の削除
  Future<int> deleteMoodRecord(int id) async {
    final db = await database;
    return await db.delete(
      'mood_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
