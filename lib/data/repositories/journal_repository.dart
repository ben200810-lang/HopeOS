import 'dart:convert';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  Future<List<JournalEntry>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('journal_entries', orderBy: 'updatedAt DESC');
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getRecent(int limit) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'journal_entries',
      orderBy: 'updatedAt DESC',
      limit: limit,
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> search(String query) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'journal_entries',
      where: 'content LIKE ? OR title LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<void> insert(JournalEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.insert('journal_entries', entry.toMap());
  }

  Future<void> update(JournalEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    final item = await db.query('journal_entries', where: 'id = ?', whereArgs: [id]);
    if (item.isNotEmpty) {
      await db.insert('deleted_items', {
        'id': id,
        'tableName': 'journal_entries',
        'data': jsonEncode(item.first),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<bool> undoDelete(String id) async {
    final db = await DatabaseHelper.database;
    final deleted = await db.query(
      'deleted_items',
      where: 'id = ? AND tableName = ?',
      whereArgs: [id, 'journal_entries'],
    );
    if (deleted.isEmpty) return false;

    final data = jsonDecode(deleted.first['data'] as String) as Map<String, dynamic>;
    await db.insert('journal_entries', data);
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<int> getTotalCount() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM journal_entries');
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getDeletedItems() async {
    final db = await DatabaseHelper.database;
    return db.query(
      'deleted_items',
      where: 'tableName = ?',
      whereArgs: ['journal_entries'],
      orderBy: 'deletedAt DESC',
    );
  }

  Future<void> permanentlyDelete(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> purgeExpiredItems() async {
    final db = await DatabaseHelper.database;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    await db.delete(
      'deleted_items',
      where: 'tableName = ? AND deletedAt < ?',
      whereArgs: ['journal_entries', cutoff],
    );
  }
}
