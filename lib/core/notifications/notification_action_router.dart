import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../../features/dashboard/widgets/quick_entry_sheets.dart';
import '../../features/dashboard/widgets/drink_capture_dialog.dart';

/// Routes notification action taps to the correct capture modal.
///
/// Uses a global [NavigatorState] key to obtain a [BuildContext] and
/// show the capture sheet directly — no full navigation stack is opened.
class NotificationActionRouter {
  final GlobalKey<NavigatorState> _navigatorKey;

  NotificationActionRouter(this._navigatorKey);

  /// Wire this router to [NotificationService.onActionTapped].
  void attach() {
    NotificationService.onActionTapped = _handleAction;
  }

  void _handleAction(String actionId) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    switch (actionId) {
      case NotificationService.actionNote:
        _showSheet(context, const NoteQuickSheet());
      case NotificationService.actionMood:
        _showSheet(context, const MoodQuickSheet());
      case NotificationService.actionDrink:
        _showDrinkDialog(context);
      case NotificationService.actionExpense:
        _showSheet(context, const FinanceQuickSheet(initialIsIncome: false));
      case NotificationService.actionIncome:
        _showSheet(context, const FinanceQuickSheet(initialIsIncome: true));
    }
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => sheet,
    );
  }

  void _showDrinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const DrinkCaptureDialog(),
    );
  }
}
