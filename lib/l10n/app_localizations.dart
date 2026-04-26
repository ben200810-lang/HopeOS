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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
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

  String get home;
  String get timeline;
  String get settings;
  String get profile;
  String get mood;
  String get sleep;
  String get drink;
  String get finance;
  String get notes;
  String get lifeScore;
  String get capture;
  String get insights;
  String get quickActions;
  String get note;
  String get voice;
  String get feeling;
  String get expense;
  String get todaysGoals;
  String get collectingData;
  String get lifeScoreAvailableSoon;
  String get privacy;
  String get about;
  String get adhdInsights;
  String get language;
  String get units;
  String get notifications;
  String get appearance;
  String get dailyGoals;
  String get account;
  String get editProfile;
  String get drinkType;
  String get amount;
  String get customDrinks;
  String get addCustomDrink;
  String get save;
  String get cancel;
  String get getStarted;
  String get completeProfileSetup;
  String get enableNotifications;
  String get remindersAndCheckins;
  String get lockScreenQuickCapture;
  String get captureThoughtsFromLockScreen;
  String get waterGoal;
  String get sleepGoal;
  String get exerciseGoal;
  String get drinkReminder;
  String get sleepReminder;
  String get dailyReflection;
  String get patternInsights;
  String get noInsightsYet;
  String get aboutAndLegal;
  String get missionAndFounder;
  String get howYourDataIsStored;
  String get patternAnalysisStrategies;
  String get nextSmallStep;
  String get tapToComplete;
  String get tapToGetStarted;
  String get done;
  String get latestNote;
  String get emptyNote;
  String get personalInfo;
  String get nickname;
  String get enterYourName;
  String get knowledgeBase;
  String get logDrink;
  String get log;
  String get doneNiceWork;
  String get undo;
  String get voiceNotes;
  String get voiceNotesComingSoon;
  String get gotIt;
  String get openNotes;
  String get expenseTracking;
  String get expenseTrackingComingSoon;
  String get rescueMode;
  String get letsRestart;
  String get niceMomentumStarted;
  String get aboutHopeOS;
  String get yourPersonalLifeOS;
  String get designedForAdhd;
  String get notificationPermission;
  String get notificationPermissionExplanation;
  String get allowNotifications;
  String get skipForNow;
  String get permissionDenied;
  String get notificationDeniedExplanation;
  String get healthPermission;
  String get healthPermissionExplanation;
  String get connectHealth;
  String get healthDeniedExplanation;
  String get patternInsightsV2;
  String get crossDomainPatterns;
  String get notMedicalDiagnosis;
  String get analyzingPatterns;
  String get refreshInsights;
  String get timelinePatterns;
  String get strong;
  String get possible;
  String get weak;

  // New keys
  String get basedOnTodaysActivity;
  String get thriving;
  String get doingWell;
  String get gettingThere;
  String get slowDay;
  String get startWithOneSmallStep;
  String get lifeSignals;
  String get hydration;
  String get activity;
  String get noDataYet;
  String get yourNextAction;
  String get allCaughtUp;
  String get addNewAction;
  String get todaysProgress;
  String get actions;
  String get water;
  String get exercise;
  String get takeAMomentForYourself;
  String get quickCapture;
  String todayCount(int count);
  String get whatDoYouWantToCapture;
  String get tapToLogIn1to3Taps;
  String get quickThought;
  String get audioNote;
  String get emotion;
  String get howYouFeel;
  String get logHydration;
  String get meal;
  String get whatYouAte;
  String get trackSpending;
  String get moment;
  String get specialMoment;
  String get photo;
  String get snapAndSave;
  String get backToCaptureTypes;
  String get whatsOnYourMind;
  String get saveNote;
  String get noteSaved;
  String get voiceNote;
  String get tapToStopRecording;
  String get tapToStartRecording;
  String get addTextNoteOptional;
  String get audioStoredLocally;
  String get saveVoiceNote;
  String get recordingSaved;
  String get voiceNoteSaved;
  String get howAreYouFeeling;
  String get energyLevel;
  String get quickNoteOptional;
  String get logEmotion;
  String get emotionLogged;
  String get todayLabel;
  String get coffee;
  String get tea;
  String get whatDidYouEat;
  String get breakfast;
  String get lunch;
  String get dinner;
  String get snack;
  String get logMeal;
  String get mealLogged;
  String get descriptionOptional;
  String get logExpense;
  String expenseLogged(String amount);
  String get captureSpecial;
  String get whatHappened;
  String get saveMoment;
  String get momentCaptured;
  String get takePhoto;
  String get gallery;
  String get captionOptional;
  String get photoCaptureInfo;
  String get saveWithCaption;
  String get photoEntrySaved;
  String get cameraOpeningSoon;
  String get galleryOpeningSoon;
  String get food;
  String get transport;
  String get shopping;
  String get health;
  String get bills;
  String get other;
  String drinkLoggedMessage(String emoji, String name, int ml);
  String waterLoggedMessage(int ml, String type);
  String get theme;
  String get auto;
  String get light;
  String get dark;
  String get every2Hours;
  String get dailyAt2200;
  String get dailyAt2000;
  String get yourPersonalPatterns;
  String get recycleBin;
  String get searchEntries;
  String get today;
  String get captures;
  String get all;
  String get energy;
  String get drinkSomething;
  String get walkFor2Minutes;
  String get writeOneSentence;
  String get take5DeepBreaths;
  String get stretch;
  String get lookOutside;
  String get washYourFace;
  String get putOnFavouriteSong;
  String get tidyOneSmallThing;
  String get sayGratefulThing;
  String get pickOneThatIsEnough;
  String get drinkGlassOfWater;
  String get howAreYouFeelingToday;
  String get takeAShortWalk;
  String get takeAShortBreak;
  String get logANoteAboutYourDay;
  String get checkInWithYourself;
  String get takeADeepBreath;
  String get completed;
  String get editNote;
  String get editMoment;
  String get audioRecordingSaved;
  String get noAudioRecorded;
  String get editTranscriptionNote;
  String get editDrinkType;
  String get liters;
  String get editMealDescription;
  String get editDescription;
  String get editCaption;
  String get entryUpdated;
  String get entryDeleted;
  String get general;
  String get recycleBinEmpty;
  String get deletedItemsKept;
  String get restore;
  String get deletePermanently;
  String get itemRestored;
  String get delete;
  String get empty;
  String allItemsWillBeDeleted(int count);
  String get untitledNote;
  String get locationPermission;
  String get locationPermissionExplanation;
  String get allowLocation;
  String mealLoggedType(String type);
  String get quickCaptureSection;
  String get lateSleepPattern;
  String lateSleepDescription(int percent);
  String get lowMorningHydration;
  String lowMorningHydrationDescription(int percent);
  String get spendingClusters;
  String spendingClustersDescription(int days);
  String get nightActivity;
  String nightActivityDescription(int percent);
  String get energyCrashes;
  String energyCrashesDescription(int count);

  // Timeline & Journal
  String get lifeTimeline;
  String get searchTimeline;
  String get noEntriesYet;
  String get yourLifeEventsWillAppear;
  String get recycle;
  String get movedToRecycleBin;
  String get total;
  String get newEntry;
  String get drinks;
  String get moodEnergy;
  String get rescue;
  String get searchEntries;
  String get yourCapturesAndNotesWillAppear;
  String get captures;
  String get photos;
  String get emotions;
  String get meals;
  String get expenses;
  String get moments;

  // Insights
  String get hydrationTrend;
  String get activityTrend;
  String get moodTrend;
  String get sleepTrend;
  String get spending7Days;
  String get logWaterTrend;
  String get logExerciseTrend;
  String get logMoodTrend;
  String get logSleepTrend;

  // Help
  String get todayINeedHelp;
  String get iNeedHelp;
  String get itsOkayToNeedHelp;
  String get chooseWhatFeelsRight;
  String get oneSmallStepToRestart;
  String get anotherOne;
  String get thankYou;
  String get breathing;
  String get cannotBeUndone;
  String get emptyRecycleBin;

  // Home screen improvements
  String get currentBalance;
  String get income;
  String get logIncome;
  String get recentNotes;
  String get moodLogged;
  String get transactionLogged;

  // Permissions & notifications
  String get activityRecognition;
  String get activityRecognitionExplanation;
  String get allowActivityTracking;
  String get activityDeniedExplanation;
  String get usageAccessPermission;
  String get usageAccessExplanation;
  String get allowUsageAccess;
  String get dailyCheckIn;
  String get dailyCheckInDescription;
  String get hydrationReminder;
  String get patternInsightsDescription;
  String get persistentNotificationDescription;
  String get quickCaptureNotificationTitle;
  String get quickCaptureNotificationBody;

  // Onboarding
  String get welcomeToHopeOS;
  String get letsGetToKnowYou;
  String get whatShouldWeCallYou;
  String get continueButton;
  String get howDoYouIdentify;
  String get thisHelpsPersonalize;
  String get male;
  String get female;
  String get whenWereYouBorn;
  String get staysPrivateAndLocal;
  String get pickYourDate;
  String get changeDate;
  String get yourMeasurements;
  String get storedLocallyNeverShared;
  String get heightLabel;
  String get weightLabel;
  String get nextButton;
  String get skipButton;
  String get chooseYourBodyType;
  String get helpsTrackWellness;
  String get bodySlim;
  String get bodyLean;
  String get bodyAthletic;
  String get bodyAverage;
  String get bodyStocky;
  String get bodyHeavy;
  String get bodySlimDesc;
  String get bodyLeanDesc;
  String get bodyAthleticDesc;
  String get bodyAverageDesc;
  String get bodyStockyDesc;
  String get bodyHeavyDesc;
  String get chooseYourLanguage;
  String get selectPreferredLanguage;
  String get preferredUnits;
  String get chooseHowYouMeasure;
  String get metricLabel;
  String get imperialLabel;
  String get metricUnits;
  String get imperialUnits;

  // Profile
  String get setYourName;
  String get actionsDone;
  String get journalEntriesLabel;
  String get hopeosUser;
  String get tapToSetUp;

  // Health screen
  String get physicalHealth;
  String get thisWeek;
  String get resetButton;
  String get dayMon;
  String get dayTue;
  String get dayWed;
  String get dayThu;
  String get dayFri;
  String get daySat;
  String get daySun;

  // Mental screen
  String get mentalState;
  String get historyLabel;
  String get logMood;
  String get sevenDayMoodAverage;
  String moodLevel(int level);

  // Insights screen
  String get energyToday;
  String get logExpensesToSeeTrends;
  String get doneTodayLabel;
  String get pendingLabel;
  String get avgMood;
  String get entriesLabel;
  String get energyEmpty;
  String get energyLow;
  String get energyMedium;
  String get energyHigh;
  String get energyPeak;

  // About screen
  String get personalLifeOS;
  String get founderLabel;
  String get missionLabel;
  String get motivationLabel;
  String get coreValuesLabel;
  String get missionText;
  String get motivationText;
  String get valuePrivacy;
  String get valueUnderstanding;
  String get valueEmpathy;
  String get valueGrowth;
  String get madeWithLove;

  // Privacy screen
  String get localFirstData;
  String get localFirstDataBody;
  String get noCloudSync;
  String get noCloudSyncBody;
  String get noTracking;
  String get noTrackingBody;
  String get healthData;
  String get healthDataBody;
  String get adhdInsightsPrivacy;
  String get adhdInsightsPrivacyBody;
  String get dataDeletion;
  String get dataDeletionBody;
  String get lastUpdatedApril2026;

  // Drink dialog
  String get energyDrinkLabel;
  String get customLabel;

  // Dashboard
  String get addAction;
  String get noteSavedMessage;

  // Capture edit
  String get voiceNoteLabel;
  String get quickNoteLabel;

  // Home screen
  String get recentTimeline;
  String get viewAll;
  String get title;

  // Permission onboarding
  String get permissionSetup;
  String get permissionSetupSubtitle;
  String get permissionGranted;
  String get permissionSkipped;
  String get tapToEnable;
  String get permissionDeniedTitle;
  String get permissionDeniedBody;
  String get openAppSettings;

  // Language names
  String get english;
  String get hungarian;
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
      'that was used.');
}
