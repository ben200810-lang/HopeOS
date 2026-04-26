import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Table definitions ──

class Actions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringPattern => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MoodEntries extends Table {
  TextColumn get id => text()();
  IntColumn get moodLevel => integer()();
  IntColumn get energyLevel => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class HealthEntries extends Table {
  TextColumn get id => text()();
  RealColumn get waterLiters => real().withDefault(const Constant(0.0))();
  RealColumn get sleepHours => real().nullable()();
  IntColumn get exerciseMinutes => integer().nullable()();
  IntColumn get steps => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get title => text().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Captures extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get textContent => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get moodLevel => integer().nullable()();
  IntColumn get energyLevel => integer().nullable()();
  TextColumn get metadata => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeletedItems extends Table {
  TextColumn get id => text()();
  TextColumn get tableName => text()();
  TextColumn get data => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Activity tracking (Health Connect / Google Fit) ──

class ActivityEntries extends Table {
  TextColumn get id => text()();
  TextColumn get activityType => text()();
  IntColumn get durationMinutes => integer()();
  IntColumn get steps => integer().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get caloriesBurned => integer().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Actions,
  MoodEntries,
  HealthEntries,
  JournalEntries,
  Captures,
  DeletedItems,
  ActivityEntries,
])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  factory AppDatabase() => _instance ??= AppDatabase._();

  AppDatabase._() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hopeos_v2.db'));
    return NativeDatabase.createInBackground(file);
  });
}
