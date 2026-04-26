import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/actions/action_provider.dart';
import '../../features/capture/capture_provider.dart';
import '../../features/health/health_provider.dart';
import '../../features/journal/journal_provider.dart';
import '../../features/mental/mental_provider.dart';
import '../../features/settings/settings_provider.dart';
import '../../features/timeline/timeline_provider.dart';
import '../knowledge/knowledge_service.dart';
import '../utils/navigation_provider.dart';

// ── Legacy ChangeNotifier bridges ──
// These wrap existing providers so screens can use either Provider or Riverpod.
// New code should use Riverpod directly; legacy screens can migrate gradually.

final settingsProvider = ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider()..loadSettings();
});

final actionProvider = ChangeNotifierProvider<ActionProvider>((ref) {
  return ActionProvider()..loadActions();
});

final mentalProvider = ChangeNotifierProvider<MentalProvider>((ref) {
  return MentalProvider()..loadEntries();
});

final healthProvider = ChangeNotifierProvider<HealthProvider>((ref) {
  return HealthProvider()..loadData();
});

final journalProvider = ChangeNotifierProvider<JournalProvider>((ref) {
  return JournalProvider()..loadEntries();
});

final captureProvider = ChangeNotifierProvider<CaptureProvider>((ref) {
  return CaptureProvider()..loadEntries();
});

final navigationProvider = ChangeNotifierProvider<NavigationProvider>((ref) {
  return NavigationProvider();
});

final timelineProvider = ChangeNotifierProvider<TimelineProvider>((ref) {
  return TimelineProvider();
});

// ── Native Riverpod providers ──

final knowledgeServiceProvider = Provider<KnowledgeService>((ref) {
  return KnowledgeService();
});

final knowledgeInitProvider = FutureProvider<void>((ref) async {
  final knowledge = ref.read(knowledgeServiceProvider);
  await knowledge.initialize();
});

// ── Locale ──

final localeProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.language;
});
