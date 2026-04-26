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

  /// No description provided for @basedOnTodaysActivity.
  ///
  /// In en, this message translates to:
  /// **'Based on today\'s activity'**
  String get basedOnTodaysActivity;

  /// No description provided for @thriving.
  ///
  /// In en, this message translates to:
  /// **'Thriving'**
  String get thriving;

  /// No description provided for @doingWell.
  ///
  /// In en, this message translates to:
  /// **'Doing well'**
  String get doingWell;

  /// No description provided for @gettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting there'**
  String get gettingThere;

  /// No description provided for @slowDay.
  ///
  /// In en, this message translates to:
  /// **'Slow day — that\'s okay'**
  String get slowDay;

  /// No description provided for @startWithOneSmallStep.
  ///
  /// In en, this message translates to:
  /// **'Start with one small step'**
  String get startWithOneSmallStep;

  /// No description provided for @lifeSignals.
  ///
  /// In en, this message translates to:
  /// **'Life Signals'**
  String get lifeSignals;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @yourNextAction.
  ///
  /// In en, this message translates to:
  /// **'YOUR NEXT ACTION'**
  String get yourNextAction;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @addNewAction.
  ///
  /// In en, this message translates to:
  /// **'Add a new action to keep moving forward'**
  String get addNewAction;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @takeAMomentForYourself.
  ///
  /// In en, this message translates to:
  /// **'Take a moment for yourself'**
  String get takeAMomentForYourself;

  /// No description provided for @quickCapture.
  ///
  /// In en, this message translates to:
  /// **'Quick Capture'**
  String get quickCapture;

  /// No description provided for @todayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String todayCount(int count);

  /// No description provided for @whatDoYouWantToCapture.
  ///
  /// In en, this message translates to:
  /// **'What do you want to capture?'**
  String get whatDoYouWantToCapture;

  /// No description provided for @tapToLogIn1to3Taps.
  ///
  /// In en, this message translates to:
  /// **'Tap to log in 1–3 taps'**
  String get tapToLogIn1to3Taps;

  /// No description provided for @quickThought.
  ///
  /// In en, this message translates to:
  /// **'Quick thought'**
  String get quickThought;

  /// No description provided for @audioNote.
  ///
  /// In en, this message translates to:
  /// **'Audio note'**
  String get audioNote;

  /// No description provided for @emotion.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get emotion;

  /// No description provided for @howYouFeel.
  ///
  /// In en, this message translates to:
  /// **'How you feel'**
  String get howYouFeel;

  /// No description provided for @logHydration.
  ///
  /// In en, this message translates to:
  /// **'Log hydration'**
  String get logHydration;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @whatYouAte.
  ///
  /// In en, this message translates to:
  /// **'What you ate'**
  String get whatYouAte;

  /// No description provided for @trackSpending.
  ///
  /// In en, this message translates to:
  /// **'Track spending'**
  String get trackSpending;

  /// No description provided for @moment.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get moment;

  /// No description provided for @specialMoment.
  ///
  /// In en, this message translates to:
  /// **'Special moment'**
  String get specialMoment;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @snapAndSave.
  ///
  /// In en, this message translates to:
  /// **'Snap & save'**
  String get snapAndSave;

  /// No description provided for @backToCaptureTypes.
  ///
  /// In en, this message translates to:
  /// **'Back to capture types'**
  String get backToCaptureTypes;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get voiceNote;

  /// No description provided for @tapToStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop recording'**
  String get tapToStopRecording;

  /// No description provided for @tapToStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording'**
  String get tapToStartRecording;

  /// No description provided for @addTextNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a text note (optional)'**
  String get addTextNoteOptional;

  /// No description provided for @audioStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Audio will be stored locally. Transcription coming soon.'**
  String get audioStoredLocally;

  /// No description provided for @saveVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Save Voice Note'**
  String get saveVoiceNote;

  /// No description provided for @recordingSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get recordingSaved;

  /// No description provided for @voiceNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Voice note saved'**
  String get voiceNoteSaved;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @energyLevel.
  ///
  /// In en, this message translates to:
  /// **'Energy level'**
  String get energyLevel;

  /// No description provided for @quickNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Quick note (optional)'**
  String get quickNoteOptional;

  /// No description provided for @logEmotion.
  ///
  /// In en, this message translates to:
  /// **'Log Emotion'**
  String get logEmotion;

  /// No description provided for @emotionLogged.
  ///
  /// In en, this message translates to:
  /// **'Emotion logged'**
  String get emotionLogged;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayLabel;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @tea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tea;

  /// No description provided for @whatDidYouEat.
  ///
  /// In en, this message translates to:
  /// **'What did you eat?'**
  String get whatDidYouEat;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// No description provided for @mealLogged.
  ///
  /// In en, this message translates to:
  /// **'Meal logged'**
  String get mealLogged;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @logExpense.
  ///
  /// In en, this message translates to:
  /// **'Log Expense'**
  String get logExpense;

  /// No description provided for @expenseLogged.
  ///
  /// In en, this message translates to:
  /// **'Expense logged: {amount}'**
  String expenseLogged(String amount);

  /// No description provided for @captureSpecial.
  ///
  /// In en, this message translates to:
  /// **'Capture something special'**
  String get captureSpecial;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// No description provided for @saveMoment.
  ///
  /// In en, this message translates to:
  /// **'Save Moment'**
  String get saveMoment;

  /// No description provided for @momentCaptured.
  ///
  /// In en, this message translates to:
  /// **'Moment captured'**
  String get momentCaptured;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @captionOptional.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get captionOptional;

  /// No description provided for @photoCaptureInfo.
  ///
  /// In en, this message translates to:
  /// **'Photo capture requires camera permissions. Image picker integration coming in the next update.'**
  String get photoCaptureInfo;

  /// No description provided for @saveWithCaption.
  ///
  /// In en, this message translates to:
  /// **'Save with Caption'**
  String get saveWithCaption;

  /// No description provided for @photoEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Photo entry saved'**
  String get photoEntrySaved;

  /// No description provided for @cameraOpeningSoon.
  ///
  /// In en, this message translates to:
  /// **'Camera opening soon'**
  String get cameraOpeningSoon;

  /// No description provided for @galleryOpeningSoon.
  ///
  /// In en, this message translates to:
  /// **'Gallery opening soon'**
  String get galleryOpeningSoon;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @drinkLoggedMessage.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {name} — {ml}ml logged'**
  String drinkLoggedMessage(String emoji, String name, int ml);

  /// No description provided for @waterLoggedMessage.
  ///
  /// In en, this message translates to:
  /// **'+{ml}ml {type} logged'**
  String waterLoggedMessage(int ml, String type);

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @every2Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 2 hours (8:00-22:00)'**
  String get every2Hours;

  /// No description provided for @dailyAt2200.
  ///
  /// In en, this message translates to:
  /// **'Daily at 22:00'**
  String get dailyAt2200;

  /// No description provided for @dailyAt2000.
  ///
  /// In en, this message translates to:
  /// **'Daily at 20:00'**
  String get dailyAt2000;

  /// No description provided for @yourPersonalPatterns.
  ///
  /// In en, this message translates to:
  /// **'Your personal patterns & trends'**
  String get yourPersonalPatterns;

  /// No description provided for @recycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBin;

  /// No description provided for @searchEntries.
  ///
  /// In en, this message translates to:
  /// **'Search entries...'**
  String get searchEntries;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @captures.
  ///
  /// In en, this message translates to:
  /// **'Captures'**
  String get captures;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @drinkSomething.
  ///
  /// In en, this message translates to:
  /// **'Drink something'**
  String get drinkSomething;

  /// No description provided for @walkFor2Minutes.
  ///
  /// In en, this message translates to:
  /// **'Walk for 2 minutes'**
  String get walkFor2Minutes;

  /// No description provided for @writeOneSentence.
  ///
  /// In en, this message translates to:
  /// **'Write one sentence'**
  String get writeOneSentence;

  /// No description provided for @take5DeepBreaths.
  ///
  /// In en, this message translates to:
  /// **'Take 5 deep breaths'**
  String get take5DeepBreaths;

  /// No description provided for @stretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get stretch;

  /// No description provided for @lookOutside.
  ///
  /// In en, this message translates to:
  /// **'Look outside'**
  String get lookOutside;

  /// No description provided for @washYourFace.
  ///
  /// In en, this message translates to:
  /// **'Wash your face'**
  String get washYourFace;

  /// No description provided for @putOnFavouriteSong.
  ///
  /// In en, this message translates to:
  /// **'Put on your favourite song'**
  String get putOnFavouriteSong;

  /// No description provided for @tidyOneSmallThing.
  ///
  /// In en, this message translates to:
  /// **'Tidy one small thing'**
  String get tidyOneSmallThing;

  /// No description provided for @sayGratefulThing.
  ///
  /// In en, this message translates to:
  /// **'Say one thing you\'re grateful for'**
  String get sayGratefulThing;

  /// No description provided for @pickOneThatIsEnough.
  ///
  /// In en, this message translates to:
  /// **'Pick one. That\'s enough.'**
  String get pickOneThatIsEnough;

  /// No description provided for @drinkGlassOfWater.
  ///
  /// In en, this message translates to:
  /// **'Drink a glass of water'**
  String get drinkGlassOfWater;

  /// No description provided for @howAreYouFeelingToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeelingToday;

  /// No description provided for @takeAShortWalk.
  ///
  /// In en, this message translates to:
  /// **'Take a short walk'**
  String get takeAShortWalk;

  /// No description provided for @takeAShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Take a short break'**
  String get takeAShortBreak;

  /// No description provided for @logANoteAboutYourDay.
  ///
  /// In en, this message translates to:
  /// **'Log a note about your day'**
  String get logANoteAboutYourDay;

  /// No description provided for @checkInWithYourself.
  ///
  /// In en, this message translates to:
  /// **'Check in with yourself'**
  String get checkInWithYourself;

  /// No description provided for @takeADeepBreath.
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath'**
  String get takeADeepBreath;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @editMoment.
  ///
  /// In en, this message translates to:
  /// **'Edit moment'**
  String get editMoment;

  /// No description provided for @audioRecordingSaved.
  ///
  /// In en, this message translates to:
  /// **'Audio recording saved'**
  String get audioRecordingSaved;

  /// No description provided for @noAudioRecorded.
  ///
  /// In en, this message translates to:
  /// **'No audio recorded'**
  String get noAudioRecorded;

  /// No description provided for @editTranscriptionNote.
  ///
  /// In en, this message translates to:
  /// **'Edit transcription note'**
  String get editTranscriptionNote;

  /// No description provided for @editDrinkType.
  ///
  /// In en, this message translates to:
  /// **'Edit drink type'**
  String get editDrinkType;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liters;

  /// No description provided for @editMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit meal description'**
  String get editMealDescription;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit description'**
  String get editDescription;

  /// No description provided for @editCaption.
  ///
  /// In en, this message translates to:
  /// **'Edit caption'**
  String get editCaption;

  /// No description provided for @entryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get entryUpdated;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @recycleBinEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty'**
  String get recycleBinEmpty;

  /// No description provided for @deletedItemsKept.
  ///
  /// In en, this message translates to:
  /// **'Deleted items are kept for 30 days'**
  String get deletedItemsKept;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @itemRestored.
  ///
  /// In en, this message translates to:
  /// **'Item restored'**
  String get itemRestored;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @allItemsWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'All {count} items will be permanently deleted.'**
  String allItemsWillBeDeleted(int count);

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled note'**
  String get untitledNote;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// No description provided for @locationPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'HopeOS can use your location to automatically set your language. This is optional.'**
  String get locationPermissionExplanation;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @mealLoggedType.
  ///
  /// In en, this message translates to:
  /// **'{type} logged'**
  String mealLoggedType(String type);

  /// No description provided for @quickCaptureSection.
  ///
  /// In en, this message translates to:
  /// **'Quick Capture'**
  String get quickCaptureSection;

  /// No description provided for @lateSleepPattern.
  ///
  /// In en, this message translates to:
  /// **'Late Sleep Pattern'**
  String get lateSleepPattern;

  /// No description provided for @lateSleepDescription.
  ///
  /// In en, this message translates to:
  /// **'You tend to log sleep after 23:00 ({percent}% of the time).'**
  String lateSleepDescription(int percent);

  /// No description provided for @lowMorningHydration.
  ///
  /// In en, this message translates to:
  /// **'Low Morning Hydration'**
  String get lowMorningHydration;

  /// No description provided for @lowMorningHydrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Your hydration tends to be low before 14:00. Only {percent}% of drinks are in the morning.'**
  String lowMorningHydrationDescription(int percent);

  /// No description provided for @spendingClusters.
  ///
  /// In en, this message translates to:
  /// **'Spending Clusters'**
  String get spendingClusters;

  /// No description provided for @spendingClustersDescription.
  ///
  /// In en, this message translates to:
  /// **'{days} days with 3+ expenses detected. This may indicate impulsive spending.'**
  String spendingClustersDescription(int days);

  /// No description provided for @nightActivity.
  ///
  /// In en, this message translates to:
  /// **'Night Activity'**
  String get nightActivity;

  /// No description provided for @nightActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Many notes/captures are created after 22:00 ({percent}% of entries).'**
  String nightActivityDescription(int percent);

  /// No description provided for @energyCrashes.
  ///
  /// In en, this message translates to:
  /// **'Energy Crashes'**
  String get energyCrashes;

  /// No description provided for @energyCrashesDescription.
  ///
  /// In en, this message translates to:
  /// **'Your energy drops significantly ({count} crashes detected). Consider consistent sleep and hydration.'**
  String energyCrashesDescription(int count);

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @logIncome.
  ///
  /// In en, this message translates to:
  /// **'Log Income'**
  String get logIncome;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// No description provided for @moodLogged.
  ///
  /// In en, this message translates to:
  /// **'Mood logged'**
  String get moodLogged;

  /// No description provided for @transactionLogged.
  ///
  /// In en, this message translates to:
  /// **'Transaction logged'**
  String get transactionLogged;

  /// No description provided for @activityRecognition.
  ///
  /// In en, this message translates to:
  /// **'Activity Recognition'**
  String get activityRecognition;

  /// No description provided for @activityRecognitionExplanation.
  ///
  /// In en, this message translates to:
  /// **'HopeOS uses activity data to detect patterns in your energy and habits.\n\nThis helps identify when you\'re most productive and suggests better times for tasks.'**
  String get activityRecognitionExplanation;

  /// No description provided for @allowActivityTracking.
  ///
  /// In en, this message translates to:
  /// **'Allow Activity Tracking'**
  String get allowActivityTracking;

  /// No description provided for @activityDeniedExplanation.
  ///
  /// In en, this message translates to:
  /// **'You can enable activity tracking later in Settings. HopeOS will still work without it.'**
  String get activityDeniedExplanation;

  /// No description provided for @usageAccessPermission.
  ///
  /// In en, this message translates to:
  /// **'Usage Access'**
  String get usageAccessPermission;

  /// No description provided for @usageAccessExplanation.
  ///
  /// In en, this message translates to:
  /// **'HopeOS can track your screen time to detect late-night usage patterns and help you build healthier digital habits.\n\nThis data stays on your device and is never shared.'**
  String get usageAccessExplanation;

  /// No description provided for @allowUsageAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Usage Access'**
  String get allowUsageAccess;

  /// No description provided for @dailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// No description provided for @dailyCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Morning reminder at 9:00'**
  String get dailyCheckInDescription;

  /// No description provided for @hydrationReminder.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminder'**
  String get hydrationReminder;

  /// No description provided for @patternInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications when patterns are detected'**
  String get patternInsightsDescription;

  /// No description provided for @persistentNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Show persistent notification with Note, Drink, Mood, Finance buttons'**
  String get persistentNotificationDescription;

  /// No description provided for @quickCaptureNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'HopeOS Quick Capture'**
  String get quickCaptureNotificationTitle;

  /// No description provided for @quickCaptureNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to log a note, drink, mood, or expense'**
  String get quickCaptureNotificationBody;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @voiceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get voiceNoteLabel;

  /// No description provided for @recentTimeline.
  ///
  /// In en, this message translates to:
  /// **'Recent Timeline'**
  String get recentTimeline;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @physicalHealth.
  ///
  /// In en, this message translates to:
  /// **'Physical Health'**
  String get physicalHealth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @todayINeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Today I need help'**
  String get todayINeedHelp;

  /// No description provided for @iNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'I need help'**
  String get iNeedHelp;

  /// No description provided for @itsOkayToNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to need help'**
  String get itsOkayToNeedHelp;

  /// No description provided for @chooseWhatFeelsRight.
  ///
  /// In en, this message translates to:
  /// **'Choose what feels right'**
  String get chooseWhatFeelsRight;

  /// No description provided for @oneSmallStepToRestart.
  ///
  /// In en, this message translates to:
  /// **'One small step to restart'**
  String get oneSmallStepToRestart;

  /// No description provided for @anotherOne.
  ///
  /// In en, this message translates to:
  /// **'Another one'**
  String get anotherOne;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get thankYou;

  /// No description provided for @breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// No description provided for @hydrationTrend.
  ///
  /// In en, this message translates to:
  /// **'Hydration Trend'**
  String get hydrationTrend;

  /// No description provided for @logWaterTrend.
  ///
  /// In en, this message translates to:
  /// **'Log water to see trends'**
  String get logWaterTrend;

  /// No description provided for @activityTrend.
  ///
  /// In en, this message translates to:
  /// **'Activity Trend'**
  String get activityTrend;

  /// No description provided for @logExerciseTrend.
  ///
  /// In en, this message translates to:
  /// **'Log exercise to see trends'**
  String get logExerciseTrend;

  /// No description provided for @moodTrend.
  ///
  /// In en, this message translates to:
  /// **'Mood Trend'**
  String get moodTrend;

  /// No description provided for @logMoodTrend.
  ///
  /// In en, this message translates to:
  /// **'Log mood to see trends'**
  String get logMoodTrend;

  /// No description provided for @sleepTrend.
  ///
  /// In en, this message translates to:
  /// **'Sleep Trend'**
  String get sleepTrend;

  /// No description provided for @logSleepTrend.
  ///
  /// In en, this message translates to:
  /// **'Log sleep to see trends'**
  String get logSleepTrend;

  /// No description provided for @spending7Days.
  ///
  /// In en, this message translates to:
  /// **'Spending (7 days)'**
  String get spending7Days;

  /// No description provided for @energyToday.
  ///
  /// In en, this message translates to:
  /// **'Energy Today'**
  String get energyToday;

  /// No description provided for @logExpensesToSeeTrends.
  ///
  /// In en, this message translates to:
  /// **'Log expenses to see trends'**
  String get logExpensesToSeeTrends;

  /// No description provided for @doneTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Done Today'**
  String get doneTodayLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @avgMood.
  ///
  /// In en, this message translates to:
  /// **'Avg Mood'**
  String get avgMood;

  /// No description provided for @entriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entriesLabel;

  /// No description provided for @energyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get energyEmpty;

  /// No description provided for @energyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get energyLow;

  /// No description provided for @energyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get energyMedium;

  /// No description provided for @energyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get energyHigh;

  /// No description provided for @energyPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get energyPeak;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @moments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get moments;

  /// No description provided for @yourCapturesAndNotesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your captures and notes will appear here'**
  String get yourCapturesAndNotesWillAppear;

  /// No description provided for @recycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get recycle;

  /// No description provided for @movedToRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Moved to recycle bin'**
  String get movedToRecycleBin;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get cannotBeUndone;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Empty Recycle Bin'**
  String get emptyRecycleBin;

  /// No description provided for @mentalState.
  ///
  /// In en, this message translates to:
  /// **'Mental State'**
  String get mentalState;

  /// No description provided for @sevenDayMoodAverage.
  ///
  /// In en, this message translates to:
  /// **'7-day mood average'**
  String get sevenDayMoodAverage;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// No description provided for @moodLevel.
  ///
  /// In en, this message translates to:
  /// **'Mood {level}/5'**
  String moodLevel(int level);

  /// No description provided for @welcomeToHopeOS.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HopeOS'**
  String get welcomeToHopeOS;

  /// No description provided for @letsGetToKnowYou.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get letsGetToKnowYou;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatShouldWeCallYou;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @howDoYouIdentify.
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get howDoYouIdentify;

  /// No description provided for @thisHelpsPersonalize.
  ///
  /// In en, this message translates to:
  /// **'This helps personalize your experience'**
  String get thisHelpsPersonalize;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @whenWereYouBorn.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get whenWereYouBorn;

  /// No description provided for @staysPrivateAndLocal.
  ///
  /// In en, this message translates to:
  /// **'Stays private and local'**
  String get staysPrivateAndLocal;

  /// No description provided for @pickYourDate.
  ///
  /// In en, this message translates to:
  /// **'Pick your date'**
  String get pickYourDate;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDate;

  /// No description provided for @yourMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Your measurements'**
  String get yourMeasurements;

  /// No description provided for @storedLocallyNeverShared.
  ///
  /// In en, this message translates to:
  /// **'Stored locally, never shared'**
  String get storedLocallyNeverShared;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @chooseYourBodyType.
  ///
  /// In en, this message translates to:
  /// **'Choose your body type'**
  String get chooseYourBodyType;

  /// No description provided for @helpsTrackWellness.
  ///
  /// In en, this message translates to:
  /// **'Helps track wellness goals'**
  String get helpsTrackWellness;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @bodySlim.
  ///
  /// In en, this message translates to:
  /// **'Slim'**
  String get bodySlim;

  /// No description provided for @bodyLean.
  ///
  /// In en, this message translates to:
  /// **'Lean'**
  String get bodyLean;

  /// No description provided for @bodyAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get bodyAthletic;

  /// No description provided for @bodyAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get bodyAverage;

  /// No description provided for @bodyStocky.
  ///
  /// In en, this message translates to:
  /// **'Stocky'**
  String get bodyStocky;

  /// No description provided for @bodyHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get bodyHeavy;

  /// No description provided for @bodySlimDesc.
  ///
  /// In en, this message translates to:
  /// **'Narrow frame, low muscle'**
  String get bodySlimDesc;

  /// No description provided for @bodyLeanDesc.
  ///
  /// In en, this message translates to:
  /// **'Slim with some definition'**
  String get bodyLeanDesc;

  /// No description provided for @bodyAthleticDesc.
  ///
  /// In en, this message translates to:
  /// **'Muscular and defined'**
  String get bodyAthleticDesc;

  /// No description provided for @bodyAverageDesc.
  ///
  /// In en, this message translates to:
  /// **'Moderate build'**
  String get bodyAverageDesc;

  /// No description provided for @bodyStockyDesc.
  ///
  /// In en, this message translates to:
  /// **'Broad, solid frame'**
  String get bodyStockyDesc;

  /// No description provided for @bodyHeavyDesc.
  ///
  /// In en, this message translates to:
  /// **'Larger, full build'**
  String get bodyHeavyDesc;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// No description provided for @preferredUnits.
  ///
  /// In en, this message translates to:
  /// **'Preferred units'**
  String get preferredUnits;

  /// No description provided for @chooseHowYouMeasure.
  ///
  /// In en, this message translates to:
  /// **'Choose how you measure'**
  String get chooseHowYouMeasure;

  /// No description provided for @metricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metricLabel;

  /// No description provided for @metricUnits.
  ///
  /// In en, this message translates to:
  /// **'kg, cm, °C'**
  String get metricUnits;

  /// No description provided for @imperialLabel.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperialLabel;

  /// No description provided for @imperialUnits.
  ///
  /// In en, this message translates to:
  /// **'lb, in, °F'**
  String get imperialUnits;

  /// No description provided for @permissionSetup.
  ///
  /// In en, this message translates to:
  /// **'Permission Setup'**
  String get permissionSetup;

  /// No description provided for @permissionSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help HopeOS work better for you'**
  String get permissionSetupSubtitle;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You can enable this later in Settings.'**
  String get permissionDeniedBody;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get permissionSkipped;

  /// No description provided for @tapToEnable.
  ///
  /// In en, this message translates to:
  /// **'Tap to enable'**
  String get tapToEnable;

  /// No description provided for @setYourName.
  ///
  /// In en, this message translates to:
  /// **'Set your name'**
  String get setYourName;

  /// No description provided for @actionsDone.
  ///
  /// In en, this message translates to:
  /// **'Actions Done'**
  String get actionsDone;

  /// No description provided for @journalEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal Entries'**
  String get journalEntriesLabel;

  /// No description provided for @personalLifeOS.
  ///
  /// In en, this message translates to:
  /// **'Personal Life OS'**
  String get personalLifeOS;

  /// No description provided for @founderLabel.
  ///
  /// In en, this message translates to:
  /// **'Founder'**
  String get founderLabel;

  /// No description provided for @missionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get missionLabel;

  /// No description provided for @missionText.
  ///
  /// In en, this message translates to:
  /// **'To help people with ADHD understand themselves and take small meaningful actions every day.'**
  String get missionText;

  /// No description provided for @motivationLabel.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get motivationLabel;

  /// No description provided for @motivationText.
  ///
  /// In en, this message translates to:
  /// **'Built from personal experience with ADHD, HopeOS aims to be the companion I always wished I had.'**
  String get motivationText;

  /// No description provided for @coreValuesLabel.
  ///
  /// In en, this message translates to:
  /// **'Core Values'**
  String get coreValuesLabel;

  /// No description provided for @valuePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get valuePrivacy;

  /// No description provided for @valueUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Understanding'**
  String get valueUnderstanding;

  /// No description provided for @valueEmpathy.
  ///
  /// In en, this message translates to:
  /// **'Empathy'**
  String get valueEmpathy;

  /// No description provided for @valueGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get valueGrowth;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with love'**
  String get madeWithLove;

  /// No description provided for @localFirstData.
  ///
  /// In en, this message translates to:
  /// **'Local-First Data'**
  String get localFirstData;

  /// No description provided for @localFirstDataBody.
  ///
  /// In en, this message translates to:
  /// **'All your data is stored locally on your device. Nothing is sent to any server.'**
  String get localFirstDataBody;

  /// No description provided for @noCloudSync.
  ///
  /// In en, this message translates to:
  /// **'No Cloud Sync'**
  String get noCloudSync;

  /// No description provided for @noCloudSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device. No cloud sync, no external servers.'**
  String get noCloudSyncBody;

  /// No description provided for @noTracking.
  ///
  /// In en, this message translates to:
  /// **'No Tracking'**
  String get noTracking;

  /// No description provided for @noTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'HopeOS does not track you. No analytics, no ads, no data collection.'**
  String get noTrackingBody;

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// No description provided for @healthDataBody.
  ///
  /// In en, this message translates to:
  /// **'Health data from Health Connect is processed locally and never leaves your device.'**
  String get healthDataBody;

  /// No description provided for @adhdInsightsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'ADHD Insights Privacy'**
  String get adhdInsightsPrivacy;

  /// No description provided for @adhdInsightsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Pattern analysis runs entirely on your device. No data is shared externally.'**
  String get adhdInsightsPrivacyBody;

  /// No description provided for @dataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get dataDeletion;

  /// No description provided for @dataDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete all your data at any time from Settings.'**
  String get dataDeletionBody;

  /// No description provided for @lastUpdatedApril2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: April 2026'**
  String get lastUpdatedApril2026;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hungarian.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get hungarian;

  /// No description provided for @searchTimeline.
  ///
  /// In en, this message translates to:
  /// **'Search timeline...'**
  String get searchTimeline;

  /// No description provided for @lifeTimeline.
  ///
  /// In en, this message translates to:
  /// **'Life Timeline'**
  String get lifeTimeline;

  /// No description provided for @yourLifeEventsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your life events will appear here'**
  String get yourLifeEventsWillAppear;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @moodEnergy.
  ///
  /// In en, this message translates to:
  /// **'Mood & Energy'**
  String get moodEnergy;

  /// No description provided for @rescue.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get rescue;
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
