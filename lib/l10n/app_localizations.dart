import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en')
  ];

  /// Application title shown in the OS task switcher + on the splash.
  ///
  /// In en, this message translates to:
  /// **'Laratik Schools'**
  String get appTitle;

  /// No description provided for @navStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get navStudents;

  /// No description provided for @navStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navStaff;

  /// No description provided for @navGuardians.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get navGuardians;

  /// No description provided for @navAcademics.
  ///
  /// In en, this message translates to:
  /// **'Academics'**
  String get navAcademics;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navMyClasses.
  ///
  /// In en, this message translates to:
  /// **'My classes'**
  String get navMyClasses;

  /// No description provided for @navFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get navFees;

  /// No description provided for @shellDashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get shellDashboard;

  /// No description provided for @shellNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get shellNotifications;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get commonClearSearch;

  /// No description provided for @commonNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get commonNoResults;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @homeParentMyChildren.
  ///
  /// In en, this message translates to:
  /// **'My children'**
  String get homeParentMyChildren;

  /// No description provided for @homeParentNoChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'No children linked yet'**
  String get homeParentNoChildrenTitle;

  /// No description provided for @homeParentNoChildrenMessage.
  ///
  /// In en, this message translates to:
  /// **'When the school links you as a guardian, your children\'s names will appear here. If you expected to see a child and you don\'t, contact the school office to confirm the link is in place.'**
  String get homeParentNoChildrenMessage;

  /// No description provided for @homeParentInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get homeParentInbox;

  /// No description provided for @homeParentInboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new messages'**
  String get homeParentInboxEmpty;

  /// No description provided for @homeParentInboxUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new messages} =1{1 unread message} other{{count} unread messages}}'**
  String homeParentInboxUnread(int count);

  /// No description provided for @homeStudentMySchool.
  ///
  /// In en, this message translates to:
  /// **'My school'**
  String get homeStudentMySchool;

  /// No description provided for @homeStudentResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving student…'**
  String get homeStudentResolving;

  /// No description provided for @homeStudentResolvingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the active student for this device.'**
  String get homeStudentResolvingMessage;

  /// No description provided for @homeStudentResolvingFailed.
  ///
  /// In en, this message translates to:
  /// **'Student resolution failed'**
  String get homeStudentResolvingFailed;

  /// No description provided for @homeStudentNoStudent.
  ///
  /// In en, this message translates to:
  /// **'No student resolved'**
  String get homeStudentNoStudent;

  /// No description provided for @homeStudentNoStudentMessage.
  ///
  /// In en, this message translates to:
  /// **'No students are seeded on this site yet.'**
  String get homeStudentNoStudentMessage;

  /// No description provided for @homeStudentSwitchStudent.
  ///
  /// In en, this message translates to:
  /// **'Switch student'**
  String get homeStudentSwitchStudent;

  /// No description provided for @homeStudentToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeStudentToday;

  /// No description provided for @homeStudentMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeStudentMore;

  /// No description provided for @homeStudentAllExams.
  ///
  /// In en, this message translates to:
  /// **'All exams'**
  String get homeStudentAllExams;

  /// No description provided for @homeStudentAllExamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse every published exam'**
  String get homeStudentAllExamsSubtitle;

  /// No description provided for @homeStudentMyRecords.
  ///
  /// In en, this message translates to:
  /// **'My records'**
  String get homeStudentMyRecords;

  /// No description provided for @homeStudentMyRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grades, attendance, and report cards'**
  String get homeStudentMyRecordsSubtitle;

  /// No description provided for @homeTeacherMySchool.
  ///
  /// In en, this message translates to:
  /// **'My school'**
  String get homeTeacherMySchool;

  /// No description provided for @homeTeacherMyClasses.
  ///
  /// In en, this message translates to:
  /// **'My classes'**
  String get homeTeacherMyClasses;

  /// No description provided for @homeTeacherCaptureAttendance.
  ///
  /// In en, this message translates to:
  /// **'Capture attendance'**
  String get homeTeacherCaptureAttendance;

  /// No description provided for @homeTeacherCaptureAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark a class group'**
  String get homeTeacherCaptureAttendanceSubtitle;

  /// No description provided for @homeAdminQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get homeAdminQuickStart;

  /// No description provided for @homeAdminPracticeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Practice quiz'**
  String get homeAdminPracticeQuiz;

  /// No description provided for @homeAdminPracticeQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a published exam'**
  String get homeAdminPracticeQuizSubtitle;

  /// No description provided for @homeAdminNewStudent.
  ///
  /// In en, this message translates to:
  /// **'New student'**
  String get homeAdminNewStudent;

  /// No description provided for @homeAdminNewStudentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enrol from the registrar'**
  String get homeAdminNewStudentSubtitle;

  /// No description provided for @homeAdminNewStaff.
  ///
  /// In en, this message translates to:
  /// **'New staff'**
  String get homeAdminNewStaff;

  /// No description provided for @homeAdminNewStaffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a teacher or admin'**
  String get homeAdminNewStaffSubtitle;

  /// No description provided for @homeAdminNewSubject.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get homeAdminNewSubject;

  /// No description provided for @homeAdminNewSubjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a subject to the catalog'**
  String get homeAdminNewSubjectSubtitle;

  /// No description provided for @homeAdminFeePlans.
  ///
  /// In en, this message translates to:
  /// **'Fee plans'**
  String get homeAdminFeePlans;

  /// No description provided for @homeAdminFeePlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review issued + outstanding plans'**
  String get homeAdminFeePlansSubtitle;

  /// No description provided for @homeAdminFeeOperations.
  ///
  /// In en, this message translates to:
  /// **'Fee operations'**
  String get homeAdminFeeOperations;

  /// No description provided for @homeAdminFeeOperationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invoiced / collected / outstanding'**
  String get homeAdminFeeOperationsSubtitle;

  /// No description provided for @myChildrenHeaderTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No linked children} =1{1 linked child} other{{count} linked children}}'**
  String myChildrenHeaderTotal(int count);

  /// No description provided for @myChildrenHeaderActive.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {inactive} withdrawn. Withdrawn links are kept for reference.'**
  String myChildrenHeaderActive(int active, int inactive);

  /// No description provided for @myChildrenHeaderAllActive.
  ///
  /// In en, this message translates to:
  /// **'Tap a child to see their grades, attendance, and report cards.'**
  String get myChildrenHeaderAllActive;

  /// No description provided for @myChildrenChildCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get myChildrenChildCurrent;

  /// No description provided for @myChildrenChildActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myChildrenChildActive;

  /// No description provided for @meSwitchStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch student'**
  String get meSwitchStudentTitle;

  /// No description provided for @meSwitchStudentSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or student number'**
  String get meSwitchStudentSearch;

  /// No description provided for @meSwitchStudentNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No students match \"{query}\"'**
  String meSwitchStudentNoResultsTitle(String query);

  /// No description provided for @meSwitchStudentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No students yet'**
  String get meSwitchStudentEmptyTitle;

  /// No description provided for @meSwitchStudentEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a student to the roster, then come back here to pick one.'**
  String get meSwitchStudentEmptyMessage;

  /// No description provided for @meSwitchStudentSearchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Searching students'**
  String get meSwitchStudentSearchingTitle;

  /// No description provided for @meSwitchStudentSearchingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the roster.'**
  String get meSwitchStudentSearchingMessage;

  /// No description provided for @meSwitchStudentNowActingAs.
  ///
  /// In en, this message translates to:
  /// **'Now acting as {name}'**
  String meSwitchStudentNowActingAs(String name);

  /// No description provided for @myClassesHeaderTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active assignments} =1{1 active assignment} other{{count} active assignments}}'**
  String myClassesHeaderTotal(int count);

  /// No description provided for @myClassesHeaderActive.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {inactive} inactive. Inactive assignments are kept for reference.'**
  String myClassesHeaderActive(int active, int inactive);

  /// No description provided for @myClassesHeaderAllActive.
  ///
  /// In en, this message translates to:
  /// **'Tap a class to see your roster + exams for that subject.'**
  String get myClassesHeaderAllActive;

  /// No description provided for @myClassesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No classes assigned'**
  String get myClassesEmptyTitle;

  /// No description provided for @myClassesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active teaching assignments yet. When the registrar assigns you to a (class, subject) pair, the class will appear here.'**
  String get myClassesEmptyMessage;

  /// No description provided for @myClassesLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your classes'**
  String get myClassesLoadingTitle;

  /// No description provided for @myClassesLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the (class, subject) pairs you teach.'**
  String get myClassesLoadingMessage;

  /// No description provided for @myClassesChipHomeroom.
  ///
  /// In en, this message translates to:
  /// **'Homeroom'**
  String get myClassesChipHomeroom;

  /// No description provided for @classDetailRosterTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading roster'**
  String get classDetailRosterTitle;

  /// No description provided for @classDetailRosterMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the students assigned to this class group.'**
  String get classDetailRosterMessage;

  /// No description provided for @classDetailRosterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No students in this class yet'**
  String get classDetailRosterEmptyTitle;

  /// No description provided for @classDetailRosterEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No students are assigned to this class group yet. When the registrar enrols students, they will appear here automatically.'**
  String get classDetailRosterEmptyMessage;

  /// No description provided for @classDetailHeaderClassGroup.
  ///
  /// In en, this message translates to:
  /// **'Class group'**
  String get classDetailHeaderClassGroup;

  /// No description provided for @childDetailTitleOwn.
  ///
  /// In en, this message translates to:
  /// **'My records'**
  String get childDetailTitleOwn;

  /// No description provided for @childDetailTitleOther.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get childDetailTitleOther;

  /// No description provided for @childDetailTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get childDetailTabOverview;

  /// No description provided for @childDetailTabGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get childDetailTabGrades;

  /// No description provided for @childDetailTabAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get childDetailTabAttendance;

  /// No description provided for @childDetailTabReports.
  ///
  /// In en, this message translates to:
  /// **'Report cards'**
  String get childDetailTabReports;

  /// No description provided for @childDetailOverviewKpiGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get childDetailOverviewKpiGrades;

  /// No description provided for @childDetailOverviewKpiAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get childDetailOverviewKpiAverage;

  /// No description provided for @childDetailOverviewKpiAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get childDetailOverviewKpiAttendance;

  /// No description provided for @childDetailOverviewKpiReports.
  ///
  /// In en, this message translates to:
  /// **'Report cards'**
  String get childDetailOverviewKpiReports;

  /// No description provided for @childDetailOverviewMessageOwn.
  ///
  /// In en, this message translates to:
  /// **'A quick summary of your grades, attendance, and report cards. Open a tab above for the full list.'**
  String get childDetailOverviewMessageOwn;

  /// No description provided for @childDetailOverviewMessageOther.
  ///
  /// In en, this message translates to:
  /// **'A quick summary of this child\'s grades, attendance, and report cards. Open a tab above for the full list.'**
  String get childDetailOverviewMessageOther;

  /// No description provided for @childDetailOverviewTitleOwn.
  ///
  /// In en, this message translates to:
  /// **'Your records at a glance'**
  String get childDetailOverviewTitleOwn;

  /// No description provided for @childDetailOverviewTitleOther.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get childDetailOverviewTitleOther;

  /// No description provided for @childDetailGradesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get childDetailGradesEmptyTitle;

  /// No description provided for @childDetailGradesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No published grades for this student yet. New grades appear here as soon as teachers release them.'**
  String get childDetailGradesEmptyMessage;

  /// No description provided for @childDetailAttendanceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded'**
  String get childDetailAttendanceEmptyTitle;

  /// No description provided for @childDetailAttendanceEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No attendance has been recorded for this student yet. Daily attendance will appear here as it\'s captured.'**
  String get childDetailAttendanceEmptyMessage;

  /// No description provided for @childDetailReportsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No report cards yet'**
  String get childDetailReportsEmptyTitle;

  /// No description provided for @childDetailReportsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No report cards have been published for this student yet. Term summaries appear here once the school releases them.'**
  String get childDetailReportsEmptyMessage;

  /// No description provided for @childDetailEmptyStateFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not load records'**
  String get childDetailEmptyStateFallback;

  /// No description provided for @childDetailNoStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'No student resolved for this device'**
  String get childDetailNoStudentTitle;

  /// No description provided for @childDetailNoStudentMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t resolve the student this device is acting as. Sign out and back in, or contact the school office if the issue persists.'**
  String get childDetailNoStudentMessage;

  /// No description provided for @feePlansHeaderTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No fee plans} =1{1 fee plan} other{{count} fee plans}}'**
  String feePlansHeaderTotal(int count);

  /// No description provided for @feePlansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No fee plans yet'**
  String get feePlansEmptyTitle;

  /// No description provided for @feePlansEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active fee plans yet. When the school issues a plan for your child, it will appear here with the per-line breakdown and a payment status.'**
  String get feePlansEmptyMessage;

  /// No description provided for @feePlansLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading fee plans'**
  String get feePlansLoadingTitle;

  /// No description provided for @feePlansLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the latest fee plans from the server.'**
  String get feePlansLoadingMessage;

  /// No description provided for @feePlansBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get feePlansBreakdown;

  /// No description provided for @a11yRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get a11yRefreshTooltip;

  /// No description provided for @a11yNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get a11yNotificationsTooltip;

  /// No description provided for @a11ySwitchStudentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch student'**
  String get a11ySwitchStudentTooltip;

  /// No description provided for @a11yActingAs.
  ///
  /// In en, this message translates to:
  /// **'Acting as {name}'**
  String a11yActingAs(String name);

  /// No description provided for @a11yUnreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unread messages} =1{1 unread message} other{{count} unread messages}}'**
  String a11yUnreadNotifications(int count);
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
