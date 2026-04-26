import 'dart:convert';
import '../database/database_helper.dart';
import '../models/action_item.dart';

class ActionRepository {
  Future<List<ActionItem>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('actions', orderBy: 'priority ASC, createdAt DESC');
    return maps.map((map) => ActionItem.fromMap(map)).toList();
  }

  Future<List<ActionItem>> getPending() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'actions',
      where: 'isCompleted = 0',
      orderBy: 'priority ASC, createdAt DESC',
    );
    return maps.map((map) => ActionItem.fromMap(map)).toList();
  }

  Future<List<ActionItem>> getCompleted() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'actions',
      where: 'isCompleted = 1',
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => ActionItem.fromMap(map)).toList();
  }

  Future<ActionItem?> getNextAction() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'actions',
      where: 'isCompleted = 0',
      orderBy: 'priority ASC, createdAt ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ActionItem.fromMap(maps.first);
  }

  Future<void> insert(ActionItem action) async {
    final db = await DatabaseHelper.database;
    await db.insert('actions', action.toMap());
  }

  Future<void> update(ActionItem action) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'actions',
      action.toMap(),
      where: 'id = ?',
      whereArgs: [action.id],
    );
  }

  Future<void> complete(String id) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'actions',
      {
        'isCompleted': 1,
        'completedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> uncomplete(String id) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'actions',
      {
        'isCompleted': 0,
        'completedAt': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    // Save to deleted_items for undo
    final item = await db.query('actions', where: 'id = ?', whereArgs: [id]);
    if (item.isNotEmpty) {
      await db.insert('deleted_items', {
        'id': id,
        'tableName': 'actions',
        'data': jsonEncode(item.first),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await db.delete('actions', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<bool> undoDelete(String id) async {
    final db = await DatabaseHelper.database;
    final deleted = await db.query(
      'deleted_items',
      where: 'id = ? AND tableName = ?',
      whereArgs: [id, 'actions'],
    );
    if (deleted.isEmpty) return false;

    final data = jsonDecode(deleted.first['data'] as String) as Map<String, dynamic>;
    await db.insert('actions', data);
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<int> getTodayCompletedCount() async {
    final db = await DatabaseHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM actions WHERE isCompleted = 1 AND completedAt >= ?',
      [startOfDay],
    );
    return result.first['count'] as int;
  }
}
