import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'hopeos.db';
  static const int _dbVersion = 3;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE actions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        priority INTEGER NOT NULL DEFAULT 2,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPattern TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        moodLevel INTEGER NOT NULL,
        energyLevel INTEGER NOT NULL,
        note TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE health_entries (
        id TEXT PRIMARY KEY,
        waterLiters REAL NOT NULL DEFAULT 0,
        sleepHours REAL,
        exerciseMinutes INTEGER,
        steps INTEGER,
        note TEXT,
        date TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        title TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE deleted_items (
        id TEXT PRIMARY KEY,
        tableName TEXT NOT NULL,
        data TEXT NOT NULL,
        deletedAt TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_actions_completed ON actions(isCompleted)');
    await db.execute(
        'CREATE INDEX idx_actions_category ON actions(category)');
    await db.execute(
        'CREATE INDEX idx_mood_created ON mood_entries(createdAt)');
    await db.execute(
        'CREATE INDEX idx_health_date ON health_entries(date)');
    await db.execute(
        'CREATE INDEX idx_journal_created ON journal_entries(createdAt)');

    await _createCapturesTable(db);
  }

  static Future<void> _createCapturesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS captures (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        text TEXT,
        audioPath TEXT,
        imagePath TEXT,
        amount REAL,
        category TEXT,
        moodLevel INTEGER,
        energyLevel INTEGER,
        metadata TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_captures_created ON captures(createdAt)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_captures_type ON captures(type)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCapturesTable(db);
    }
    if (oldVersion < 3) {
      try {
        await db.execute(
            'ALTER TABLE captures ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // Column may already exist
      }
    }
  }
}
