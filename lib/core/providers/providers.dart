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
// These are overridden in main.dart's ProviderScope with the same instances
// used by the legacy Provider package. This ensures state stays in sync
// regardless of whether a screen reads from Provider or Riverpod.

final settingsRiverpod = ChangeNotifierProvider<SettingsProvider>((ref) {
  throw UnimplementedError(
      'settingsRiverpod must be overridden in ProviderScope');
});

final actionRiverpod = ChangeNotifierProvider<ActionProvider>((ref) {
  throw UnimplementedError(
      'actionRiverpod must be overridden in ProviderScope');
});

final mentalRiverpod = ChangeNotifierProvider<MentalProvider>((ref) {
  throw UnimplementedError(
      'mentalRiverpod must be overridden in ProviderScope');
});

final healthRiverpod = ChangeNotifierProvider<HealthProvider>((ref) {
  throw UnimplementedError(
      'healthRiverpod must be overridden in ProviderScope');
});

final journalRiverpod = ChangeNotifierProvider<JournalProvider>((ref) {
  throw UnimplementedError(
      'journalRiverpod must be overridden in ProviderScope');
});

final captureRiverpod = ChangeNotifierProvider<CaptureProvider>((ref) {
  throw UnimplementedError(
      'captureRiverpod must be overridden in ProviderScope');
});

final navigationRiverpod = ChangeNotifierProvider<NavigationProvider>((ref) {
  throw UnimplementedError(
      'navigationRiverpod must be overridden in ProviderScope');
});

final timelineRiverpod = ChangeNotifierProvider<TimelineProvider>((ref) {
  throw UnimplementedError(
      'timelineRiverpod must be overridden in ProviderScope');
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
  final settings = ref.watch(settingsRiverpod);
  return settings.language;
});
