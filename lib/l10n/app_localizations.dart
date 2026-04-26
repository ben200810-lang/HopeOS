import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @lifeScore.
  ///
  /// In en, this message translates to:
  /// **'Life Score'**
  String get lifeScore;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @feeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get feeling;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @todaysGoals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goals'**
  String get todaysGoals;

  /// No description provided for @collectingData.
  ///
  /// In en, this message translates to:
  /// **'Collecting your data to understand your patterns.'**
  String get collectingData;

  /// No description provided for @lifeScoreAvailableSoon.
  ///
  /// In en, this message translates to:
  /// **'Life Score will appear after enough data is collected.'**
  String get lifeScoreAvailableSoon;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @adhdInsights.
  ///
  /// In en, this message translates to:
  /// **'ADHD Insights'**
  String get adhdInsights;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @dailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoals;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @drinkType.
  ///
  /// In en, this message translates to:
  /// **'Drink type'**
  String get drinkType;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @customDrinks.
  ///
  /// In en, this message translates to:
  /// **'Custom drinks'**
  String get customDrinks;

  /// No description provided for @addCustomDrink.
  ///
  /// In en, this message translates to:
  /// **'Add custom drink'**
  String get addCustomDrink;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @completeProfileSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile Setup'**
  String get completeProfileSetup;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @remindersAndCheckins.
  ///
  /// In en, this message translates to:
  /// **'Reminders and daily check-ins'**
  String get remindersAndCheckins;

  /// No description provided for @lockScreenQuickCapture.
  ///
  /// In en, this message translates to:
  /// **'Lock screen quick capture'**
  String get lockScreenQuickCapture;

  /// No description provided for @captureThoughtsFromLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Capture thoughts from lock screen'**
  String get captureThoughtsFromLockScreen;

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Water Goal'**
  String get waterGoal;

  /// No description provided for @sleepGoal.
  ///
  /// In en, this message translates to:
  /// **'Sleep Goal'**
  String get sleepGoal;

  /// No description provided for @exerciseGoal.
  ///
  /// In en, this message translates to:
  /// **'Exercise Goal'**
  String get exerciseGoal;

  /// No description provided for @drinkReminder.
  ///
  /// In en, this message translates to:
  /// **'Drink reminder'**
  String get drinkReminder;

  /// No description provided for @sleepReminder.
  ///
  /// In en, this message translates to:
  /// **'Sleep reminder'**
  String get sleepReminder;

  /// No description provided for @dailyReflection.
  ///
  /// In en, this message translates to:
  /// **'Daily reflection'**
  String get dailyReflection;

  /// No description provided for @patternInsights.
  ///
  /// In en, this message translates to:
  /// **'Pattern Insights'**
  String get patternInsights;

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'Keep logging data to discover your patterns.'**
  String get noInsightsYet;

  /// No description provided for @aboutAndLegal.
  ///
  /// In en, this message translates to:
  /// **'About & Legal'**
  String get aboutAndLegal;

  /// No description provided for @missionAndFounder.
  ///
  /// In en, this message translates to:
  /// **'Mission, founder & values'**
  String get missionAndFounder;

  /// No description provided for @howYourDataIsStored.
  ///
  /// In en, this message translates to:
  /// **'How your data is stored'**
  String get howYourDataIsStored;

  /// No description provided for @patternAnalysisStrategies.
  ///
  /// In en, this message translates to:
  /// **'Pattern analysis & strategies'**
  String get patternAnalysisStrategies;

  /// No description provided for @nextSmallStep.
  ///
  /// In en, this message translates to:
  /// **'NEXT SMALL STEP'**
  String get nextSmallStep;

  /// No description provided for @tapToComplete.
  ///
  /// In en, this message translates to:
  /// **'Tap to complete'**
  String get tapToComplete;

  /// No description provided for @tapToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Tap to get started'**
  String get tapToGetStarted;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @latestNote.
  ///
  /// In en, this message translates to:
  /// **'Latest Note'**
  String get latestNote;

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty note'**
  String get emptyNote;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// No description provided for @logDrink.
  ///
  /// In en, this message translates to:
  /// **'Log Drink'**
  String get logDrink;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @doneNiceWork.
  ///
  /// In en, this message translates to:
  /// **'Done! Nice work.'**
  String get doneNiceWork;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @voiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Voice Notes'**
  String get voiceNotes;

  /// No description provided for @voiceNotesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice recording is coming soon.\n\nFor now, try the Note button to jot down your thoughts quickly.'**
  String get voiceNotesComingSoon;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @openNotes.
  ///
  /// In en, this message translates to:
  /// **'Open Notes'**
  String get openNotes;

  /// No description provided for @expenseTracking.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracking'**
  String get expenseTracking;

  /// No description provided for @expenseTrackingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking is coming soon.\n\nThis will let you quickly log daily spending to keep your finances in check.'**
  String get expenseTrackingComingSoon;

  /// No description provided for @rescueMode.
  ///
  /// In en, this message translates to:
  /// **'Rescue Mode'**
  String get rescueMode;

  /// No description provided for @letsRestart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s restart with one small step.'**
  String get letsRestart;

  /// No description provided for @niceMomentumStarted.
  ///
  /// In en, this message translates to:
  /// **'Nice. Momentum started.'**
  String get niceMomentumStarted;

  /// No description provided for @aboutHopeOS.
  ///
  /// In en, this message translates to:
  /// **'About HopeOS'**
  String get aboutHopeOS;

  /// No description provided for @yourPersonalLifeOS.
  ///
  /// In en, this message translates to:
  /// **'Your personal life operating system'**
  String get yourPersonalLifeOS;

  /// No description provided for @designedForAdhd.
  ///
  /// In en, this message translates to:
  /// **'Designed for ADHD minds. Built with care.'**
  String get designedForAdhd;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'HopeOS needs notification permission to send you gentle reminders for water, sleep, and daily reflections.'**
  String get notificationPermissionExplanation;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @notificationDeniedExplanation.
  ///
  /// In en, this message translates to:
  /// **'You can enable notifications later in Settings to receive helpful reminders.'**
  String get notificationDeniedExplanation;

  /// No description provided for @healthPermission.
  ///
  /// In en, this message translates to:
  /// **'Health Permission'**
  String get healthPermission;

  /// No description provided for @healthPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'HopeOS can track your steps and activity using Health Connect for a more complete picture of your day.'**
  String get healthPermissionExplanation;

  /// No description provided for @connectHealth.
  ///
  /// In en, this message translates to:
  /// **'Connect Health'**
  String get connectHealth;

  /// No description provided for @healthDeniedExplanation.
  ///
  /// In en, this message translates to:
  /// **'You can connect Health Connect later in Settings to track your activity automatically.'**
  String get healthDeniedExplanation;

  /// No description provided for @patternInsightsV2.
  ///
  /// In en, this message translates to:
  /// **'Pattern Insights'**
  String get patternInsightsV2;

  /// No description provided for @crossDomainPatterns.
  ///
  /// In en, this message translates to:
  /// **'Cross-domain patterns from your life data'**
  String get crossDomainPatterns;

  /// No description provided for @notMedicalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'This is not a medical diagnosis. These are possible patterns from your data.'**
  String get notMedicalDiagnosis;

  /// No description provided for @analyzingPatterns.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your patterns...'**
  String get analyzingPatterns;

  /// No description provided for @refreshInsights.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshInsights;

  /// No description provided for @timelinePatterns.
  ///
  /// In en, this message translates to:
  /// **'Timeline Patterns'**
  String get timelinePatterns;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @possible.
  ///
  /// In en, this message translates to:
  /// **'Possible'**
  String get possible;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
