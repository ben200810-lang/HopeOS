import 'package:flutter/material.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/action_item.dart';
import '../../data/repositories/action_repository.dart';

class ActionProvider extends ChangeNotifier {
  final ActionRepository _repository = ActionRepository();

  List<ActionItem> _pendingActions = [];
  List<ActionItem> _completedActions = [];
  ActionItem? _nextAction;
  int _todayCompleted = 0;
  bool _isLoading = true;

  List<ActionItem> get pendingActions => _pendingActions;
  List<ActionItem> get completedActions => _completedActions;
  ActionItem? get nextAction => _nextAction;
  int get todayCompleted => _todayCompleted;
  bool get isLoading => _isLoading;

  Future<void> loadActions() async {
    _isLoading = true;
    notifyListeners();

    _pendingActions = await _repository.getPending();
    _completedActions = await _repository.getCompleted();
    _nextAction = await _repository.getNextAction();
    _todayCompleted = await _repository.getTodayCompletedCount();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAction({
    required String title,
    String? description,
    String category = 'custom',
    int priority = 2,
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    final action = ActionItem(
      id: IdGenerator.generate(),
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      priority: priority,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
    );
    await _repository.insert(action);
    await loadActions();
  }

  Future<void> completeAction(String id) async {
    await _repository.complete(id);
    await loadActions();
  }

  Future<void> uncompleteAction(String id) async {
    await _repository.uncomplete(id);
    await loadActions();
  }

  Future<void> updateAction(ActionItem action) async {
    await _repository.update(action);
    await loadActions();
  }

  Future<String> deleteAction(String id) async {
    await _repository.delete(id);
    await loadActions();
    return id;
  }

  Future<bool> undoDelete(String id) async {
    final result = await _repository.undoDelete(id);
    if (result) await loadActions();
    return result;
  }
}
