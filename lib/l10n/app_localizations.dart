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

  /// No description provided for @homeStudentGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeStudentGreeting(String name);

  /// No description provided for @homeStudentStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {id}'**
  String homeStudentStudentId(String id);

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

  /// No description provided for @homeStudentNoExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'No exams today'**
  String get homeStudentNoExamsTitle;

  /// No description provided for @homeStudentNoExamsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no published exam plans waiting for you. New exams will appear here as teachers publish them.'**
  String get homeStudentNoExamsMessage;

  /// No description provided for @homeStudentLoadingExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading exams'**
  String get homeStudentLoadingExamsTitle;

  /// No description provided for @homeStudentLoadingExamsMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching your published exam catalog.'**
  String get homeStudentLoadingExamsMessage;

  /// No description provided for @homeStudentCouldNotLoadExams.
  ///
  /// In en, this message translates to:
  /// **'Could not load exams'**
  String get homeStudentCouldNotLoadExams;

  /// No description provided for @homeStudentTakeNextExam.
  ///
  /// In en, this message translates to:
  /// **'Take your next exam'**
  String get homeStudentTakeNextExam;

  /// No description provided for @homeStudentOpenExam.
  ///
  /// In en, this message translates to:
  /// **'Open exam'**
  String get homeStudentOpenExam;

  /// No description provided for @homeStudentInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox + announcements'**
  String get homeStudentInboxSubtitle;

  /// No description provided for @homeParentMyFamily.
  ///
  /// In en, this message translates to:
  /// **'My family'**
  String get homeParentMyFamily;

  /// No description provided for @homeParentFeeInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee invoices'**
  String get homeParentFeeInvoicesTitle;

  /// No description provided for @homeParentFeeInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your children\'s fee plans and payment status.'**
  String get homeParentFeeInvoicesSubtitle;

  /// No description provided for @homeParentHeroLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the students you are linked to.'**
  String get homeParentHeroLoadingMessage;

  /// No description provided for @homeParentHeroLoadingChip.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get homeParentHeroLoadingChip;

  /// No description provided for @homeParentHeroErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your children just now. Tap to retry.'**
  String get homeParentHeroErrorMessage;

  /// No description provided for @homeParentHeroErrorChip.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeParentHeroErrorChip;

  /// No description provided for @homeParentLinkedChildren.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No linked children} =1{1 linked child} other{{count} linked children}}'**
  String homeParentLinkedChildren(int count);

  /// No description provided for @homeParentLinkedChildrenActive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 linked child · tap to see grades, attendance, and report cards.} other{{count} linked children · {active} active. Tap to see grades, attendance, and report cards.}}'**
  String homeParentLinkedChildrenActive(int count, int active);

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

  /// No description provided for @homeTeacherInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox + announcements'**
  String get homeTeacherInboxSubtitle;

  /// No description provided for @homeTeacherQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get homeTeacherQuickStart;

  /// No description provided for @homeTeacherHeroLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the (class, subject) pairs you teach.'**
  String get homeTeacherHeroLoadingMessage;

  /// No description provided for @homeTeacherHeroLoadingChip.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get homeTeacherHeroLoadingChip;

  /// No description provided for @homeTeacherHeroErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your classes just now. Tap to retry.'**
  String get homeTeacherHeroErrorMessage;

  /// No description provided for @homeTeacherHeroErrorChip.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeTeacherHeroErrorChip;

  /// No description provided for @homeTeacherHeroActive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 teaching assignment · tap to see your roster + exams for that subject.} other{{count} teaching assignments · {active} active. Tap to see your roster + exams for that subject.}}'**
  String homeTeacherHeroActive(int count, int active);

  /// No description provided for @homeTeacherHeroEmpty.
  ///
  /// In en, this message translates to:
  /// **'When the registrar assigns you to a (class, subject) pair, the class will appear here.'**
  String get homeTeacherHeroEmpty;

  /// No description provided for @homeAdminMyHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeAdminMyHome;

  /// No description provided for @homeAdminActingAs.
  ///
  /// In en, this message translates to:
  /// **'Acting as: {name}'**
  String homeAdminActingAs(String name);

  /// No description provided for @homeAdminSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as: {role}'**
  String homeAdminSignedInAs(String role);

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

  /// No description provided for @homeAdminCaptureAttendance.
  ///
  /// In en, this message translates to:
  /// **'Capture attendance'**
  String get homeAdminCaptureAttendance;

  /// No description provided for @homeAdminCaptureAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark a class group'**
  String get homeAdminCaptureAttendanceSubtitle;

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

  /// No description provided for @homeAdminNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox + announcements'**
  String get homeAdminNotificationsSubtitle;

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

  /// No description provided for @familyHomeLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your children'**
  String get familyHomeLoadingTitle;

  /// No description provided for @familyHomeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your children'**
  String get familyHomeErrorTitle;

  /// No description provided for @familyChildRowRelation.
  ///
  /// In en, this message translates to:
  /// **'as {relation}'**
  String familyChildRowRelation(String relation);

  /// No description provided for @familyChildRowId.
  ///
  /// In en, this message translates to:
  /// **'ID {code}'**
  String familyChildRowId(String code);

  /// No description provided for @childDetailLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading records'**
  String get childDetailLoadingTitle;

  /// No description provided for @childDetailLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Pulling grades, attendance, and report cards.'**
  String get childDetailLoadingMessage;

  /// No description provided for @childDetailGradeAssessmentFallback.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get childDetailGradeAssessmentFallback;

  /// No description provided for @childDetailGradePass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get childDetailGradePass;

  /// No description provided for @childDetailGradeFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get childDetailGradeFail;

  /// No description provided for @childDetailGradePublishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String childDetailGradePublishedOn(String date);

  /// No description provided for @childDetailReportCardFallback.
  ///
  /// In en, this message translates to:
  /// **'Report card'**
  String get childDetailReportCardFallback;

  /// No description provided for @childDetailAverageOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get childDetailAverageOnTrack;

  /// No description provided for @childDetailAverageBelowTarget.
  ///
  /// In en, this message translates to:
  /// **'Below target'**
  String get childDetailAverageBelowTarget;

  /// No description provided for @childDetailAverageNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get childDetailAverageNoGrades;

  /// No description provided for @childDetailGradesAllPassed.
  ///
  /// In en, this message translates to:
  /// **'All passed'**
  String get childDetailGradesAllPassed;

  /// No description provided for @childDetailGradesOfTotalPassed.
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} passed'**
  String childDetailGradesOfTotalPassed(int passed, int total);

  /// No description provided for @childDetailAttendanceNoAbsences.
  ///
  /// In en, this message translates to:
  /// **'No absences'**
  String get childDetailAttendanceNoAbsences;

  /// No description provided for @childDetailAttendanceKpiSub.
  ///
  /// In en, this message translates to:
  /// **'{present} present · {absent} absent'**
  String childDetailAttendanceKpiSub(int present, int absent);

  /// No description provided for @childDetailAttendanceKpiSubLate.
  ///
  /// In en, this message translates to:
  /// **'{present} present · {absent} absent · {late} late'**
  String childDetailAttendanceKpiSubLate(int present, int absent, int late);

  /// No description provided for @childDetailReportCardNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get childDetailReportCardNoCards;

  /// No description provided for @childDetailReportCardLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest: {label}'**
  String childDetailReportCardLatest(String label);

  /// No description provided for @meSwitchStudentErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load students'**
  String get meSwitchStudentErrorTitle;

  /// No description provided for @meSwitchStudentNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter search, or clear the search to see the full roster.'**
  String get meSwitchStudentNoResultsMessage;

  /// No description provided for @myClassesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your classes'**
  String get myClassesErrorTitle;

  /// No description provided for @myClassesAcademicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic year {year}'**
  String myClassesAcademicYear(String year);

  /// No description provided for @classDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classDetailTitle;

  /// No description provided for @classDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load roster'**
  String get classDetailErrorTitle;

  /// No description provided for @classDetailStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String classDetailStudentCount(int count);

  /// No description provided for @feePlansScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee plans'**
  String get feePlansScreenTitle;

  /// No description provided for @feePlansErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load fee plans'**
  String get feePlansErrorTitle;

  /// No description provided for @feePlansOverdueChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String feePlansOverdueChip(int count);

  /// No description provided for @feePlansPartialChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 partial} other{{count} partial}}'**
  String feePlansPartialChip(int count);

  /// No description provided for @feePlansPaidChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 paid} other{{count} paid}}'**
  String feePlansPaidChip(int count);

  /// No description provided for @feePlansAmountLine.
  ///
  /// In en, this message translates to:
  /// **'{currency} {total} total · outstanding {currency} {outstanding}'**
  String feePlansAmountLine(String currency, String total, String outstanding);

  /// No description provided for @feePlansAmountOnly.
  ///
  /// In en, this message translates to:
  /// **'{currency} {total}'**
  String feePlansAmountOnly(String currency, String total);

  /// No description provided for @feePlanDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee plan'**
  String get feePlanDetailTitle;

  /// No description provided for @feePlanLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading fee plan'**
  String get feePlanLoadingTitle;

  /// No description provided for @feePlanLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking up the per-line breakdown and payment status.'**
  String get feePlanLoadingMessage;

  /// No description provided for @feePlanErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load fee plan'**
  String get feePlanErrorTitle;

  /// No description provided for @feePlanNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee plan not found'**
  String get feePlanNotFoundTitle;

  /// No description provided for @feePlanNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this fee plan in the current catalog. It may have been cancelled or moved to a different academic year; head back to the list to see the latest plans.'**
  String get feePlanNotFoundMessage;

  /// No description provided for @feePlanNotFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Back to fee plans'**
  String get feePlanNotFoundAction;

  /// No description provided for @feePlanNoBreakdownMessage.
  ///
  /// In en, this message translates to:
  /// **'The server didn\'t return a per-line breakdown for this plan. The total amount is shown above; the itemized list lands when the plan is itemized on the server side.'**
  String get feePlanNoBreakdownMessage;

  /// No description provided for @feePlanIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fee plan {id}'**
  String feePlanIdentitySubtitle(String id);

  /// No description provided for @feePlanDueDateChip.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String feePlanDueDateChip(String date);

  /// No description provided for @feePlanTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get feePlanTotalLabel;

  /// No description provided for @feePlanPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get feePlanPaidLabel;

  /// No description provided for @feePlanOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get feePlanOutstandingLabel;

  /// No description provided for @feeOperationsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee operations'**
  String get feeOperationsScreenTitle;

  /// No description provided for @feeOperationsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading operations'**
  String get feeOperationsLoadingTitle;

  /// No description provided for @feeOperationsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Aggregating the latest invoice + payment totals.'**
  String get feeOperationsLoadingMessage;

  /// No description provided for @feeOperationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load operations'**
  String get feeOperationsErrorTitle;

  /// No description provided for @feeOperationsCollectionRate.
  ///
  /// In en, this message translates to:
  /// **'Collection rate'**
  String get feeOperationsCollectionRate;

  /// No description provided for @feeOperationsNoInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get feeOperationsNoInvoices;

  /// No description provided for @feeOperationsNoInvoicesMessage.
  ///
  /// In en, this message translates to:
  /// **'The school hasn\'t issued any invoices yet. The rate will appear as soon as the first plan is published.'**
  String get feeOperationsNoInvoicesMessage;

  /// No description provided for @feeOperationsCollectedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{collectedCurrency} {collectedAmount} of {totalCurrency} {totalAmount} collected so far.'**
  String feeOperationsCollectedOfTotal(String collectedCurrency,
      String collectedAmount, String totalCurrency, String totalAmount);

  /// No description provided for @feeOperationsInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get feeOperationsInvoiced;

  /// No description provided for @feeOperationsInvoicedSub.
  ///
  /// In en, this message translates to:
  /// **'Total issued this period'**
  String get feeOperationsInvoicedSub;

  /// No description provided for @feeOperationsCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get feeOperationsCollected;

  /// No description provided for @feeOperationsCollectedSub.
  ///
  /// In en, this message translates to:
  /// **'Total received so far'**
  String get feeOperationsCollectedSub;

  /// No description provided for @feeOperationsOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get feeOperationsOutstanding;

  /// No description provided for @feeOperationsOutstandingSub.
  ///
  /// In en, this message translates to:
  /// **'Still due'**
  String get feeOperationsOutstandingSub;

  /// No description provided for @feeOperationsByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get feeOperationsByStatus;

  /// No description provided for @feeOperationsPaidCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 paid} other{{count} paid}}'**
  String feeOperationsPaidCountChip(int count);

  /// No description provided for @feeOperationsOverdueCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String feeOperationsOverdueCountChip(int count);

  /// No description provided for @feeOperationsDraftCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft} other{{count} draft}}'**
  String feeOperationsDraftCountChip(int count);

  /// No description provided for @feeOperationsViewPlansAction.
  ///
  /// In en, this message translates to:
  /// **'View fee plans'**
  String get feeOperationsViewPlansAction;
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
