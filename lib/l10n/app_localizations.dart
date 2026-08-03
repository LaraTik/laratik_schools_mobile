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

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

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

  /// No description provided for @homeStudentFeeInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'My fee invoices'**
  String get homeStudentFeeInvoicesTitle;

  /// No description provided for @homeStudentFeeInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Issued + outstanding plans'**
  String get homeStudentFeeInvoicesSubtitle;

  /// No description provided for @homeParentPrivacyRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a privacy request'**
  String get homeParentPrivacyRequestTitle;

  /// No description provided for @homeParentPrivacyRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data access, erasure, or correction'**
  String get homeParentPrivacyRequestSubtitle;

  /// No description provided for @homeStudentPrivacyRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a privacy request'**
  String get homeStudentPrivacyRequestTitle;

  /// No description provided for @homeStudentPrivacyRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data access, erasure, or correction'**
  String get homeStudentPrivacyRequestSubtitle;

  /// No description provided for @studentDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentDetailScreenTitle;

  /// No description provided for @studentDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load student'**
  String get studentDetailErrorTitle;

  /// No description provided for @studentDetailLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading student'**
  String get studentDetailLoadingTitle;

  /// No description provided for @studentDetailEnrollmentHeader.
  ///
  /// In en, this message translates to:
  /// **'Current enrollment'**
  String get studentDetailEnrollmentHeader;

  /// No description provided for @studentDetailIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Identity & contact'**
  String get studentDetailIdentityHeader;

  /// No description provided for @studentDetailGuardiansHeader.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get studentDetailGuardiansHeader;

  /// No description provided for @studentDetailRecentGradesHeader.
  ///
  /// In en, this message translates to:
  /// **'Recent grades'**
  String get studentDetailRecentGradesHeader;

  /// No description provided for @studentDetailGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentDetailGradeLabel;

  /// No description provided for @studentDetailClassGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Class group'**
  String get studentDetailClassGroupLabel;

  /// No description provided for @studentDetailAcademicYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Academic year'**
  String get studentDetailAcademicYearLabel;

  /// No description provided for @studentDetailStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get studentDetailStatusLabel;

  /// No description provided for @studentDetailEnrollmentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Enrollment status'**
  String get studentDetailEnrollmentStatusLabel;

  /// No description provided for @studentDetailActivationLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get studentDetailActivationLabel;

  /// No description provided for @studentDetailNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get studentDetailNationalityLabel;

  /// No description provided for @studentDetailCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get studentDetailCountryLabel;

  /// No description provided for @studentDetailErpnextCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'ERPNext customer'**
  String get studentDetailErpnextCustomerLabel;

  /// No description provided for @studentDetailNoDataLabel.
  ///
  /// In en, this message translates to:
  /// **'No data on file.'**
  String get studentDetailNoDataLabel;

  /// No description provided for @studentDetailNoGuardianChip.
  ///
  /// In en, this message translates to:
  /// **'No guardian on file'**
  String get studentDetailNoGuardianChip;

  /// No description provided for @studentDetailCountryWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Country needs review'**
  String get studentDetailCountryWarningTitle;

  /// No description provided for @studentDetailCountryDefaultedMessage.
  ///
  /// In en, this message translates to:
  /// **'Country was defaulted from nationality; confirm with the operator.'**
  String get studentDetailCountryDefaultedMessage;

  /// No description provided for @studentDetailCountryMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Nationality and residential country differ; double-check before grading.'**
  String get studentDetailCountryMismatchMessage;

  /// No description provided for @studentCreateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'New student'**
  String get studentCreateScreenTitle;

  /// No description provided for @studentCreateLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading form'**
  String get studentCreateLoadingTitle;

  /// No description provided for @studentCreateLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the school setup context.'**
  String get studentCreateLoadingMessage;

  /// No description provided for @studentCreateSchemaErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load the form schema'**
  String get studentCreateSchemaErrorTitle;

  /// No description provided for @studentCreateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Student created'**
  String get studentCreateSuccessTitle;

  /// No description provided for @studentCreateSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'The student record is on file.'**
  String get studentCreateSuccessFallback;

  /// No description provided for @studentCreateCountryDefaultedChip.
  ///
  /// In en, this message translates to:
  /// **'Country defaulted from nationality'**
  String get studentCreateCountryDefaultedChip;

  /// No description provided for @studentCreateCountryMismatchChip.
  ///
  /// In en, this message translates to:
  /// **'Country ≠ nationality'**
  String get studentCreateCountryMismatchChip;

  /// No description provided for @studentCreateWarningsChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 warning} other{{count} warnings}}'**
  String studentCreateWarningsChip(int count);

  /// No description provided for @studentCreateAnotherAction.
  ///
  /// In en, this message translates to:
  /// **'Create another'**
  String get studentCreateAnotherAction;

  /// No description provided for @studentCreateOpenRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Open record'**
  String get studentCreateOpenRecordAction;

  /// No description provided for @studentCreateSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Create student'**
  String get studentCreateSubmitAction;

  /// No description provided for @studentCreateSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get studentCreateSubmitLoading;

  /// No description provided for @studentCreateRequiredRolesChip.
  ///
  /// In en, this message translates to:
  /// **'Requires: {roles}'**
  String studentCreateRequiredRolesChip(String roles);

  /// No description provided for @studentCreateIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get studentCreateIdentityHeader;

  /// No description provided for @studentCreateFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get studentCreateFirstNameLabel;

  /// No description provided for @studentCreateFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'As it appears on the birth certificate'**
  String get studentCreateFirstNameHint;

  /// No description provided for @studentCreateLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get studentCreateLastNameLabel;

  /// No description provided for @studentCreateDateOfBirthHeader.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get studentCreateDateOfBirthHeader;

  /// No description provided for @studentCreateDateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get studentCreateDateOfBirthLabel;

  /// No description provided for @studentCreateDateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get studentCreateDateOfBirthHint;

  /// No description provided for @studentCreateCountryNationalityHeader.
  ///
  /// In en, this message translates to:
  /// **'Country & nationality'**
  String get studentCreateCountryNationalityHeader;

  /// No description provided for @studentCreateNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get studentCreateNationalityLabel;

  /// No description provided for @studentCreateNationalityHint.
  ///
  /// In en, this message translates to:
  /// **'The nationality on file'**
  String get studentCreateNationalityHint;

  /// No description provided for @studentCreateCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country of residence'**
  String get studentCreateCountryLabel;

  /// No description provided for @studentCreateCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Where the student lives'**
  String get studentCreateCountryHint;

  /// No description provided for @studentCreateGuardianHeader.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get studentCreateGuardianHeader;

  /// No description provided for @studentCreateGuardianNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian name'**
  String get studentCreateGuardianNameLabel;

  /// No description provided for @studentCreateGuardianPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian phone'**
  String get studentCreateGuardianPhoneLabel;

  /// No description provided for @studentCreateEnrollmentHeader.
  ///
  /// In en, this message translates to:
  /// **'Enrollment'**
  String get studentCreateEnrollmentHeader;

  /// No description provided for @studentCreateGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentCreateGradeLabel;

  /// No description provided for @studentCreateGradeHint.
  ///
  /// In en, this message translates to:
  /// **'Grade 1'**
  String get studentCreateGradeHint;

  /// No description provided for @studentCreateNotesHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get studentCreateNotesHeader;

  /// No description provided for @studentCreateNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get studentCreateNotesLabel;

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

  /// No description provided for @homeAdminOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get homeAdminOperations;

  /// No description provided for @homeAdminOperationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System health, delivery, audit log'**
  String get homeAdminOperationsSubtitle;

  /// No description provided for @homeAdminGovernance.
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get homeAdminGovernance;

  /// No description provided for @homeAdminGovernanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy requests, legal hold, retention'**
  String get homeAdminGovernanceSubtitle;

  /// No description provided for @homeAdminGrading.
  ///
  /// In en, this message translates to:
  /// **'Grading'**
  String get homeAdminGrading;

  /// No description provided for @homeAdminGradingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview, policies, per-record review'**
  String get homeAdminGradingSubtitle;

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

  /// No description provided for @operationsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operationsScreenTitle;

  /// No description provided for @operationsTabHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get operationsTabHealth;

  /// No description provided for @operationsTabDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get operationsTabDelivery;

  /// No description provided for @operationsTabAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get operationsTabAudit;

  /// No description provided for @operationsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading operations health'**
  String get operationsLoadingTitle;

  /// No description provided for @operationsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Aggregating the latest per-module KPI snapshot.'**
  String get operationsLoadingMessage;

  /// No description provided for @operationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load operations'**
  String get operationsErrorTitle;

  /// No description provided for @operationsSystemHealth.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get operationsSystemHealth;

  /// No description provided for @operationsStatusHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get operationsStatusHealthy;

  /// No description provided for @operationsStatusDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get operationsStatusDegraded;

  /// No description provided for @operationsStatusUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get operationsStatusUnhealthy;

  /// No description provided for @operationsGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated at {timestamp}'**
  String operationsGeneratedAt(String timestamp);

  /// No description provided for @operationsModulesHeader.
  ///
  /// In en, this message translates to:
  /// **'Per-module KPIs'**
  String get operationsModulesHeader;

  /// No description provided for @operationsModulesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No module KPIs yet'**
  String get operationsModulesEmptyTitle;

  /// No description provided for @operationsModulesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The server hasn\'t reported any per-module metrics. They\'ll appear here as soon as the first snapshot lands.'**
  String get operationsModulesEmptyMessage;

  /// No description provided for @operationsModuleAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get operationsModuleAnalytics;

  /// No description provided for @operationsModuleAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get operationsModuleAudit;

  /// No description provided for @operationsModuleDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get operationsModuleDelivery;

  /// No description provided for @operationsModuleImports.
  ///
  /// In en, this message translates to:
  /// **'Imports'**
  String get operationsModuleImports;

  /// No description provided for @operationsModuleOutbox.
  ///
  /// In en, this message translates to:
  /// **'Outbox'**
  String get operationsModuleOutbox;

  /// No description provided for @operationsDeliveryLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading delivery health'**
  String get operationsDeliveryLoadingTitle;

  /// No description provided for @operationsDeliveryLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Aggregating the per-status delivery counts.'**
  String get operationsDeliveryLoadingMessage;

  /// No description provided for @operationsDeliveryByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get operationsDeliveryByStatus;

  /// No description provided for @operationsDeliveryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deliveries yet'**
  String get operationsDeliveryEmptyTitle;

  /// No description provided for @operationsDeliveryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The delivery queue is empty. Counts will appear here as soon as the server starts dispatching events.'**
  String get operationsDeliveryEmptyMessage;

  /// No description provided for @operationsDeliveryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total deliveries'**
  String get operationsDeliveryTotal;

  /// No description provided for @operationsDeliveryTotalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Across all statuses for this period'**
  String get operationsDeliveryTotalSubtitle;

  /// No description provided for @operationsAuditLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading audit events'**
  String get operationsAuditLoadingTitle;

  /// No description provided for @operationsAuditLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the most recent login / logout / token / device events.'**
  String get operationsAuditLoadingMessage;

  /// No description provided for @operationsAuditEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No audit events yet'**
  String get operationsAuditEmptyTitle;

  /// No description provided for @operationsAuditEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The auth audit log is empty. Events will appear here as the school uses the mobile app.'**
  String get operationsAuditEmptyMessage;

  /// No description provided for @operationsAuditUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get operationsAuditUnknownUser;

  /// No description provided for @operationsAuditFromIp.
  ///
  /// In en, this message translates to:
  /// **'From {ip}'**
  String operationsAuditFromIp(String ip);

  /// No description provided for @governanceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get governanceScreenTitle;

  /// No description provided for @governanceLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading privacy requests'**
  String get governanceLoadingTitle;

  /// No description provided for @governanceLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Aggregating the latest privacy + legal hold queue.'**
  String get governanceLoadingMessage;

  /// No description provided for @governanceErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load privacy requests'**
  String get governanceErrorTitle;

  /// No description provided for @governanceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No privacy requests'**
  String get governanceEmptyTitle;

  /// No description provided for @governanceEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty. When a parent or staff member submits a request (data export / deletion / consent / legal hold), it\'ll appear here for review.'**
  String get governanceEmptyMessage;

  /// No description provided for @governanceQueueHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No requests} =1{1 privacy request} other{{count} privacy requests}}'**
  String governanceQueueHeader(int count);

  /// No description provided for @governanceLegalHoldCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 under legal hold} other{{count} under legal hold}}'**
  String governanceLegalHoldCountChip(int count);

  /// No description provided for @governanceLegalHoldChip.
  ///
  /// In en, this message translates to:
  /// **'Legal hold'**
  String get governanceLegalHoldChip;

  /// No description provided for @governanceUnknownSubject.
  ///
  /// In en, this message translates to:
  /// **'Unknown subject'**
  String get governanceUnknownSubject;

  /// No description provided for @governanceActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Request actions'**
  String get governanceActionsTitle;

  /// No description provided for @governanceActionProcess.
  ///
  /// In en, this message translates to:
  /// **'Mark as in review'**
  String get governanceActionProcess;

  /// No description provided for @governanceActionProcessDescription.
  ///
  /// In en, this message translates to:
  /// **'Move this request to \"Under Review\" so the team knows it\'s being worked on.'**
  String get governanceActionProcessDescription;

  /// No description provided for @governanceActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve request'**
  String get governanceActionApprove;

  /// No description provided for @governanceActionApproveDescription.
  ///
  /// In en, this message translates to:
  /// **'Approve this request. The requester will be notified and the action is logged.'**
  String get governanceActionApproveDescription;

  /// No description provided for @governanceActionSetHold.
  ///
  /// In en, this message translates to:
  /// **'Set legal hold'**
  String get governanceActionSetHold;

  /// No description provided for @governanceActionSetHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Place this request under a legal hold. The data is preserved until the hold is released.'**
  String get governanceActionSetHoldDescription;

  /// No description provided for @governanceActionReleaseHold.
  ///
  /// In en, this message translates to:
  /// **'Release legal hold'**
  String get governanceActionReleaseHold;

  /// No description provided for @governanceActionReleaseHoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Release the legal hold. The request can then be approved or rejected.'**
  String get governanceActionReleaseHoldDescription;

  /// No description provided for @governanceActionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Action applied.'**
  String get governanceActionSuccess;

  /// No description provided for @governanceEvaluateRetentionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Run retention evaluation'**
  String get governanceEvaluateRetentionTooltip;

  /// No description provided for @governanceEvaluateRetentionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Retention evaluation started.'**
  String get governanceEvaluateRetentionSuccess;

  /// No description provided for @governanceEvaluateRetentionFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not start retention evaluation.'**
  String get governanceEvaluateRetentionFailure;

  /// No description provided for @gradingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Grading'**
  String get gradingScreenTitle;

  /// No description provided for @gradingTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get gradingTabOverview;

  /// No description provided for @gradingTabPolicies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get gradingTabPolicies;

  /// No description provided for @gradingLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading grading data'**
  String get gradingLoadingTitle;

  /// No description provided for @gradingLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Aggregating the latest grade records + policy catalog.'**
  String get gradingLoadingMessage;

  /// No description provided for @gradingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load grading data'**
  String get gradingErrorTitle;

  /// No description provided for @gradingKpiTotal.
  ///
  /// In en, this message translates to:
  /// **'Total grades'**
  String get gradingKpiTotal;

  /// No description provided for @gradingKpiTotalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All grade records (published + draft)'**
  String get gradingKpiTotalSubtitle;

  /// No description provided for @gradingKpiPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get gradingKpiPublished;

  /// No description provided for @gradingKpiPublishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promoted to a grade record'**
  String get gradingKpiPublishedSubtitle;

  /// No description provided for @gradingKpiDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get gradingKpiDraft;

  /// No description provided for @gradingKpiDraftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Still pending publish'**
  String get gradingKpiDraftSubtitle;

  /// No description provided for @gradingKpiAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get gradingKpiAverage;

  /// No description provided for @gradingKpiAverageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'School-wide published average'**
  String get gradingKpiAverageSubtitle;

  /// No description provided for @gradingWorkflowHeader.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get gradingWorkflowHeader;

  /// No description provided for @gradingFeatureHeader.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get gradingFeatureHeader;

  /// No description provided for @gradingFeatureValue.
  ///
  /// In en, this message translates to:
  /// **'Feature: {feature}'**
  String gradingFeatureValue(String feature);

  /// No description provided for @gradingCoverageValue.
  ///
  /// In en, this message translates to:
  /// **'Coverage: {coverage}'**
  String gradingCoverageValue(String coverage);

  /// No description provided for @gradingRecentStudentsValue.
  ///
  /// In en, this message translates to:
  /// **'Recent students: {value}'**
  String gradingRecentStudentsValue(String value);

  /// No description provided for @gradingPassThresholdValue.
  ///
  /// In en, this message translates to:
  /// **'Pass ≥ {pct}%'**
  String gradingPassThresholdValue(String pct);

  /// No description provided for @gradingPermissionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get gradingPermissionsHeader;

  /// No description provided for @gradingPermissionsDoctypesValue.
  ///
  /// In en, this message translates to:
  /// **'Manages: {doctypes}'**
  String gradingPermissionsDoctypesValue(String doctypes);

  /// No description provided for @gradingPermissionsReadRoles.
  ///
  /// In en, this message translates to:
  /// **'Read roles'**
  String get gradingPermissionsReadRoles;

  /// No description provided for @gradingPermissionsRequiredRoles.
  ///
  /// In en, this message translates to:
  /// **'Required roles for approval'**
  String get gradingPermissionsRequiredRoles;

  /// No description provided for @loginScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Laratik Schools'**
  String get loginScreenTitle;

  /// No description provided for @loginSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSignInSubtitle;

  /// No description provided for @loginOAuthPkceTitle.
  ///
  /// In en, this message translates to:
  /// **'OAuth + PKCE'**
  String get loginOAuthPkceTitle;

  /// No description provided for @loginOAuthPkceMessage.
  ///
  /// In en, this message translates to:
  /// **'S256, in-app webview, system-broker redirect.'**
  String get loginOAuthPkceMessage;

  /// No description provided for @loginSsoChip.
  ///
  /// In en, this message translates to:
  /// **'Laratik SSO'**
  String get loginSsoChip;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Laratik'**
  String get loginButton;

  /// No description provided for @loginButtonLoading.
  ///
  /// In en, this message translates to:
  /// **'Opening browser…'**
  String get loginButtonLoading;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsFilterUnread;

  /// No description provided for @notificationsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications'**
  String get notificationsLoadingTitle;

  /// No description provided for @notificationsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest inbox from the server.'**
  String get notificationsLoadingMessage;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get notificationsErrorTitle;

  /// No description provided for @studentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsTitle;

  /// No description provided for @studentsNewButton.
  ///
  /// In en, this message translates to:
  /// **'New student'**
  String get studentsNewButton;

  /// No description provided for @studentsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or student number'**
  String get studentsSearchPlaceholder;

  /// No description provided for @studentsFilterByGrade.
  ///
  /// In en, this message translates to:
  /// **'Filter by grade'**
  String get studentsFilterByGrade;

  /// No description provided for @studentsFilterByClassGroup.
  ///
  /// In en, this message translates to:
  /// **'Filter by class group'**
  String get studentsFilterByClassGroup;

  /// No description provided for @studentsGradeFilterChip.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentsGradeFilterChip;

  /// No description provided for @studentsClassGroupFilterChip.
  ///
  /// In en, this message translates to:
  /// **'Class group'**
  String get studentsClassGroupFilterChip;

  /// No description provided for @studentsFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get studentsFilterClear;

  /// No description provided for @studentsFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get studentsFilterApply;

  /// No description provided for @studentsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading students'**
  String get studentsLoadingTitle;

  /// No description provided for @studentsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest roster from the server.'**
  String get studentsLoadingMessage;

  /// No description provided for @studentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No students yet'**
  String get studentsEmptyTitle;

  /// No description provided for @studentsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When you add a student to the roster, they will appear here.'**
  String get studentsEmptyMessage;

  /// No description provided for @studentsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No students match the current filter'**
  String get studentsNoMatchTitle;

  /// No description provided for @studentsNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the search or the grade filter.'**
  String get studentsNoMatchMessage;

  /// No description provided for @studentsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load students'**
  String get studentsErrorTitle;

  /// No description provided for @studentsAddStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get studentsAddStudentButton;

  /// No description provided for @studentsFirstStudentMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first student to get started.'**
  String get studentsFirstStudentMessage;

  /// No description provided for @dataImportsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Data imports'**
  String get dataImportsScreenTitle;

  /// No description provided for @dataImportsTabBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get dataImportsTabBatches;

  /// No description provided for @dataImportsTabScoreImports.
  ///
  /// In en, this message translates to:
  /// **'Score imports'**
  String get dataImportsTabScoreImports;

  /// No description provided for @dataImportsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading data imports'**
  String get dataImportsLoadingTitle;

  /// No description provided for @dataImportsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest batches + score imports from the server.'**
  String get dataImportsLoadingMessage;

  /// No description provided for @dataImportsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load data imports'**
  String get dataImportsErrorTitle;

  /// No description provided for @dataImportsBatchesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data import batches yet'**
  String get dataImportsBatchesEmptyTitle;

  /// No description provided for @dataImportsBatchesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When a package is uploaded (via the desktop or the future mobile wizard), it will appear here.'**
  String get dataImportsBatchesEmptyMessage;

  /// No description provided for @dataImportsScoreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No score imports yet'**
  String get dataImportsScoreEmptyTitle;

  /// No description provided for @dataImportsScoreEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When a score file is uploaded (via the desktop or the future mobile wizard), it will appear here.'**
  String get dataImportsScoreEmptyMessage;

  /// No description provided for @dataImportsHashChip.
  ///
  /// In en, this message translates to:
  /// **'Hash {hash}'**
  String dataImportsHashChip(String hash);

  /// No description provided for @dataImportsRowCountChip.
  ///
  /// In en, this message translates to:
  /// **'{doctype} · {count}'**
  String dataImportsRowCountChip(String doctype, int count);

  /// No description provided for @dataImportsBatchCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted {when}'**
  String dataImportsBatchCreatedAt(String when);

  /// No description provided for @dataImportsScoreCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted {when}'**
  String dataImportsScoreCreatedAt(String when);

  /// No description provided for @dataImportsBatchDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch reconciliation'**
  String get dataImportsBatchDetailTitle;

  /// No description provided for @dataImportsBatchFallbackHeader.
  ///
  /// In en, this message translates to:
  /// **'Loading batch summary…'**
  String get dataImportsBatchFallbackHeader;

  /// No description provided for @dataImportsReconciliationHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rows} =1{1 row} other{{count} rows}}'**
  String dataImportsReconciliationHeader(int count);

  /// No description provided for @dataImportsReconciliationEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reconciliation rows'**
  String get dataImportsReconciliationEmptyTitle;

  /// No description provided for @dataImportsReconciliationEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This batch has no per-row decisions to review.'**
  String get dataImportsReconciliationEmptyMessage;

  /// No description provided for @dataImportsReconciliationDoctypeFallback.
  ///
  /// In en, this message translates to:
  /// **'Untyped row'**
  String get dataImportsReconciliationDoctypeFallback;

  /// No description provided for @dataImportsReconciliationRowIndex.
  ///
  /// In en, this message translates to:
  /// **'Row {index}'**
  String dataImportsReconciliationRowIndex(int index);

  /// No description provided for @dataImportsPayloadChip.
  ///
  /// In en, this message translates to:
  /// **'{key} · {value}'**
  String dataImportsPayloadChip(String key, String value);

  /// No description provided for @dataImportsScoreDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Score import'**
  String get dataImportsScoreDetailTitle;

  /// No description provided for @dataImportsScoreNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Score import not found'**
  String get dataImportsScoreNotFoundTitle;

  /// No description provided for @dataImportsScoreNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This score import is no longer in the school\'s catalog.'**
  String get dataImportsScoreNotFoundMessage;

  /// No description provided for @dataImportsScoreColumnsHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No columns} =1{1 column} other{{count} columns}}'**
  String dataImportsScoreColumnsHeader(int count);

  /// No description provided for @dataImportsScoreColumnChip.
  ///
  /// In en, this message translates to:
  /// **'{source} → {target}'**
  String dataImportsScoreColumnChip(String source, String target);

  /// No description provided for @dataImportsScoreColumnsChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 column} other{{count} columns}}'**
  String dataImportsScoreColumnsChip(int count);

  /// No description provided for @dataImportsScoreCountsHeader.
  ///
  /// In en, this message translates to:
  /// **'Validate counts'**
  String get dataImportsScoreCountsHeader;

  /// No description provided for @dataImportsScoreCountChip.
  ///
  /// In en, this message translates to:
  /// **'{key} · {value}'**
  String dataImportsScoreCountChip(String key, String value);

  /// No description provided for @dataImportsScoreValidateAction.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get dataImportsScoreValidateAction;

  /// No description provided for @dataImportsScoreCommitAction.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get dataImportsScoreCommitAction;

  /// No description provided for @dataImportsScoreValidatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Score import validated.'**
  String get dataImportsScoreValidatedSnack;

  /// No description provided for @dataImportsScoreCommittedSnack.
  ///
  /// In en, this message translates to:
  /// **'Score import committed.'**
  String get dataImportsScoreCommittedSnack;

  /// No description provided for @dataImportsScoreErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {message}'**
  String dataImportsScoreErrorSnack(String message);

  /// No description provided for @homeAdminDataImports.
  ///
  /// In en, this message translates to:
  /// **'Data imports'**
  String get homeAdminDataImports;

  /// No description provided for @homeAdminDataImportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review batches + score imports'**
  String get homeAdminDataImportsSubtitle;

  /// No description provided for @homeTeacherExams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get homeTeacherExams;

  /// No description provided for @homeTeacherExamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Author exam plans + grade attempts'**
  String get homeTeacherExamsSubtitle;

  /// No description provided for @teacherExamsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get teacherExamsScreenTitle;

  /// No description provided for @teacherExamsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading exams'**
  String get teacherExamsLoadingTitle;

  /// No description provided for @teacherExamsLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching your exam plans from the server.'**
  String get teacherExamsLoadingMessage;

  /// No description provided for @teacherExamsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load exams'**
  String get teacherExamsErrorTitle;

  /// No description provided for @teacherExamsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No exam plans yet'**
  String get teacherExamsEmptyTitle;

  /// No description provided for @teacherExamsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When you author an exam, it will appear here.'**
  String get teacherExamsEmptyMessage;

  /// No description provided for @teacherExamsDurationChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min} other{{minutes} min}}'**
  String teacherExamsDurationChip(int minutes);

  /// No description provided for @teacherExamsMaxScoreChip.
  ///
  /// In en, this message translates to:
  /// **'Max {score}'**
  String teacherExamsMaxScoreChip(int score);

  /// No description provided for @teacherExamDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam plan'**
  String get teacherExamDetailTitle;

  /// No description provided for @teacherExamNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam plan not found'**
  String get teacherExamNotFoundTitle;

  /// No description provided for @teacherExamNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This exam plan is no longer in the school\'s catalog.'**
  String get teacherExamNotFoundMessage;

  /// No description provided for @teacherExamStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get teacherExamStatusPublished;

  /// No description provided for @teacherExamStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get teacherExamStatusClosed;

  /// No description provided for @teacherExamStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get teacherExamStatusDraft;

  /// No description provided for @teacherExamDateChip.
  ///
  /// In en, this message translates to:
  /// **'Date {date}'**
  String teacherExamDateChip(String date);

  /// No description provided for @teacherExamMarksChip.
  ///
  /// In en, this message translates to:
  /// **'{marks, plural, =1{1 mark} other{{marks} marks}}'**
  String teacherExamMarksChip(int marks);

  /// No description provided for @teacherExamQuestionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get teacherExamQuestionsHeader;

  /// No description provided for @teacherExamQuestionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions'**
  String get teacherExamQuestionsEmptyTitle;

  /// No description provided for @teacherExamQuestionsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The subject\'s question catalog is empty. Add questions via the desktop, or the future mobile wizard.'**
  String get teacherExamQuestionsEmptyMessage;

  /// No description provided for @teacherExamQuestionFallback.
  ///
  /// In en, this message translates to:
  /// **'Untitled question'**
  String get teacherExamQuestionFallback;

  /// No description provided for @teacherExamQuestionTypeChip.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String teacherExamQuestionTypeChip(String type);

  /// No description provided for @teacherExamManualGradeAction.
  ///
  /// In en, this message translates to:
  /// **'Manual grade entry'**
  String get teacherExamManualGradeAction;

  /// No description provided for @manualGradeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual grade'**
  String get manualGradeScreenTitle;

  /// No description provided for @manualGradeAttemptHeader.
  ///
  /// In en, this message translates to:
  /// **'Attempt'**
  String get manualGradeAttemptHeader;

  /// No description provided for @manualGradeAttemptLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt ID'**
  String get manualGradeAttemptLabel;

  /// No description provided for @manualGradeAttemptHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the attempt ID from a notification or the desktop'**
  String get manualGradeAttemptHint;

  /// No description provided for @manualGradeAttemptRequired.
  ///
  /// In en, this message translates to:
  /// **'Attempt ID is required'**
  String get manualGradeAttemptRequired;

  /// No description provided for @manualGradeScoresHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No questions} =1{1 question} other{{count} questions}}'**
  String manualGradeScoresHeader(int count);

  /// No description provided for @manualGradeScoresEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions'**
  String get manualGradeScoresEmptyTitle;

  /// No description provided for @manualGradeScoresEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add questions to this plan first.'**
  String get manualGradeScoresEmptyMessage;

  /// No description provided for @manualGradeScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get manualGradeScoreLabel;

  /// No description provided for @manualGradeScoreHint.
  ///
  /// In en, this message translates to:
  /// **'0 – {max}'**
  String manualGradeScoreHint(int max);

  /// No description provided for @manualGradeScoreRequired.
  ///
  /// In en, this message translates to:
  /// **'Score is required'**
  String get manualGradeScoreRequired;

  /// No description provided for @manualGradeScoreInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get manualGradeScoreInvalid;

  /// No description provided for @manualGradeScoreNegative.
  ///
  /// In en, this message translates to:
  /// **'Score cannot be negative'**
  String get manualGradeScoreNegative;

  /// No description provided for @manualGradeScoreOverMax.
  ///
  /// In en, this message translates to:
  /// **'Score cannot exceed {max}'**
  String manualGradeScoreOverMax(int max);

  /// No description provided for @manualGradeSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit grade'**
  String get manualGradeSubmitAction;

  /// No description provided for @manualGradeSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get manualGradeSubmitLoading;

  /// No description provided for @manualGradeSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Attempt graded. New total score: {score}'**
  String manualGradeSuccessSnack(double score);

  /// No description provided for @manualGradeSuccessSnackNoScore.
  ///
  /// In en, this message translates to:
  /// **'Attempt graded.'**
  String get manualGradeSuccessSnackNoScore;

  /// No description provided for @manualGradeErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Grade failed: {message}'**
  String manualGradeErrorSnack(String message);

  /// No description provided for @teacherExamAddQuestionAction.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get teacherExamAddQuestionAction;

  /// No description provided for @teacherExamPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish exam'**
  String get teacherExamPublishAction;

  /// No description provided for @teacherExamPublishLoading.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get teacherExamPublishLoading;

  /// No description provided for @teacherExamPublishedSnack.
  ///
  /// In en, this message translates to:
  /// **'Exam published.'**
  String get teacherExamPublishedSnack;

  /// No description provided for @teacherExamPublishErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Publish failed: {message}'**
  String teacherExamPublishErrorSnack(String message);

  /// No description provided for @teacherExamQuestionPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get teacherExamQuestionPublishAction;

  /// No description provided for @teacherExamQuestionPublishLoading.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get teacherExamQuestionPublishLoading;

  /// No description provided for @teacherExamQuestionPublishedSnack.
  ///
  /// In en, this message translates to:
  /// **'Question published.'**
  String get teacherExamQuestionPublishedSnack;

  /// No description provided for @teacherExamQuestionPublishErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Publish failed: {message}'**
  String teacherExamQuestionPublishErrorSnack(String message);

  /// No description provided for @teacherExamQuestionFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get teacherExamQuestionFormTitle;

  /// No description provided for @teacherExamQuestionTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get teacherExamQuestionTypeHeader;

  /// No description provided for @teacherExamQuestionTextHeader.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get teacherExamQuestionTextHeader;

  /// No description provided for @teacherExamQuestionTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get teacherExamQuestionTextLabel;

  /// No description provided for @teacherExamQuestionTextHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to ask?'**
  String get teacherExamQuestionTextHint;

  /// No description provided for @teacherExamQuestionTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Question text is required'**
  String get teacherExamQuestionTextRequired;

  /// No description provided for @teacherExamQuestionMarksHeader.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get teacherExamQuestionMarksHeader;

  /// No description provided for @teacherExamQuestionMarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get teacherExamQuestionMarksLabel;

  /// No description provided for @teacherExamQuestionMarksHint.
  ///
  /// In en, this message translates to:
  /// **'1, 2, 5, …'**
  String get teacherExamQuestionMarksHint;

  /// No description provided for @teacherExamQuestionMarksRequired.
  ///
  /// In en, this message translates to:
  /// **'Marks is required'**
  String get teacherExamQuestionMarksRequired;

  /// No description provided for @teacherExamQuestionMarksInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get teacherExamQuestionMarksInvalid;

  /// No description provided for @teacherExamQuestionMarksNegative.
  ///
  /// In en, this message translates to:
  /// **'Marks must be greater than 0'**
  String get teacherExamQuestionMarksNegative;

  /// No description provided for @teacherExamQuestionOptionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Options ({count})'**
  String teacherExamQuestionOptionsHeader(int count);

  /// No description provided for @teacherExamQuestionAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get teacherExamQuestionAddOption;

  /// No description provided for @teacherExamQuestionSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Save question'**
  String get teacherExamQuestionSubmitAction;

  /// No description provided for @teacherExamQuestionSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get teacherExamQuestionSubmitLoading;

  /// No description provided for @teacherExamQuestionCreatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Question added.'**
  String get teacherExamQuestionCreatedSnack;

  /// No description provided for @teacherExamQuestionErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {message}'**
  String teacherExamQuestionErrorSnack(String message);

  /// No description provided for @staffListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffListScreenTitle;

  /// No description provided for @staffListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or role'**
  String get staffListSearchHint;

  /// No description provided for @staffListNewStaffAction.
  ///
  /// In en, this message translates to:
  /// **'New staff'**
  String get staffListNewStaffAction;

  /// No description provided for @staffListLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading staff'**
  String get staffListLoadingTitle;

  /// No description provided for @staffListLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest roster from the server.'**
  String get staffListLoadingMessage;

  /// No description provided for @staffListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No staff yet'**
  String get staffListEmptyTitle;

  /// No description provided for @staffListEmptyFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'No staff match the current filter'**
  String get staffListEmptyFilterTitle;

  /// No description provided for @staffListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first staff member to get started.'**
  String get staffListEmptyMessage;

  /// No description provided for @staffListEmptyFilterMessage.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the search or the role filter.'**
  String get staffListEmptyFilterMessage;

  /// No description provided for @staffListAddStaffAction.
  ///
  /// In en, this message translates to:
  /// **'Add staff'**
  String get staffListAddStaffAction;

  /// No description provided for @staffListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff'**
  String get staffListErrorTitle;

  /// No description provided for @staffListFilterRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffListFilterRole;

  /// No description provided for @staffListFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get staffListFilterClear;

  /// No description provided for @staffListFilterRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by role'**
  String get staffListFilterRoleTitle;

  /// No description provided for @staffListFilterRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get staffListFilterRoleTeacher;

  /// No description provided for @staffListFilterRolePrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get staffListFilterRolePrincipal;

  /// No description provided for @staffListFilterRoleVicePrincipal.
  ///
  /// In en, this message translates to:
  /// **'Vice Principal'**
  String get staffListFilterRoleVicePrincipal;

  /// No description provided for @staffListFilterRoleCounselor.
  ///
  /// In en, this message translates to:
  /// **'Counselor'**
  String get staffListFilterRoleCounselor;

  /// No description provided for @staffListFilterRoleLibrarian.
  ///
  /// In en, this message translates to:
  /// **'Librarian'**
  String get staffListFilterRoleLibrarian;

  /// No description provided for @staffListFilterRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get staffListFilterRoleAdmin;

  /// No description provided for @staffDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffDetailScreenTitle;

  /// No description provided for @staffDetailLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading staff'**
  String get staffDetailLoadingTitle;

  /// No description provided for @staffDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff'**
  String get staffDetailErrorTitle;

  /// No description provided for @staffDetailRoleBranchHeader.
  ///
  /// In en, this message translates to:
  /// **'Role & branch'**
  String get staffDetailRoleBranchHeader;

  /// No description provided for @staffDetailRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffDetailRoleLabel;

  /// No description provided for @staffDetailBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get staffDetailBranchLabel;

  /// No description provided for @staffDetailStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get staffDetailStatusLabel;

  /// No description provided for @staffDetailDateOfJoiningLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of joining'**
  String get staffDetailDateOfJoiningLabel;

  /// No description provided for @staffDetailUserAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'User account'**
  String get staffDetailUserAccountLabel;

  /// No description provided for @staffDetailIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Identity & contact'**
  String get staffDetailIdentityHeader;

  /// No description provided for @staffDetailGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get staffDetailGenderLabel;

  /// No description provided for @staffDetailNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get staffDetailNationalityLabel;

  /// No description provided for @staffDetailCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get staffDetailCountryLabel;

  /// No description provided for @staffDetailErpnextEmployeeLabel.
  ///
  /// In en, this message translates to:
  /// **'ERPNext employee'**
  String get staffDetailErpnextEmployeeLabel;

  /// No description provided for @staffDetailNoDataLabel.
  ///
  /// In en, this message translates to:
  /// **'No data on file.'**
  String get staffDetailNoDataLabel;

  /// No description provided for @staffStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get staffStatusActive;

  /// No description provided for @staffCreateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'New staff'**
  String get staffCreateScreenTitle;

  /// No description provided for @staffCreateLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading form'**
  String get staffCreateLoadingTitle;

  /// No description provided for @staffCreateLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the school staff setup context.'**
  String get staffCreateLoadingMessage;

  /// No description provided for @staffCreateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load the form schema'**
  String get staffCreateErrorTitle;

  /// No description provided for @staffCreateIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get staffCreateIdentityHeader;

  /// No description provided for @staffCreateFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get staffCreateFirstNameLabel;

  /// No description provided for @staffCreateLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get staffCreateLastNameLabel;

  /// No description provided for @staffCreateRoleHeader.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffCreateRoleHeader;

  /// No description provided for @staffCreateRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffCreateRoleLabel;

  /// No description provided for @staffCreateRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get staffCreateRoleHint;

  /// No description provided for @staffCreateContactHeader.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get staffCreateContactHeader;

  /// No description provided for @staffCreateEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get staffCreateEmailLabel;

  /// No description provided for @staffCreatePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get staffCreatePhoneLabel;

  /// No description provided for @staffCreateCountryHeader.
  ///
  /// In en, this message translates to:
  /// **'Country & nationality'**
  String get staffCreateCountryHeader;

  /// No description provided for @staffCreateNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get staffCreateNationalityLabel;

  /// No description provided for @staffCreateCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country of residence'**
  String get staffCreateCountryLabel;

  /// No description provided for @staffCreateDateHeader.
  ///
  /// In en, this message translates to:
  /// **'Joining date'**
  String get staffCreateDateHeader;

  /// No description provided for @staffCreateDateOfJoiningLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of joining'**
  String get staffCreateDateOfJoiningLabel;

  /// No description provided for @staffCreateDateOfJoiningHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get staffCreateDateOfJoiningHint;

  /// No description provided for @staffCreateNotesHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get staffCreateNotesHeader;

  /// No description provided for @staffCreateNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get staffCreateNotesLabel;

  /// No description provided for @staffCreateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff member created'**
  String get staffCreateSuccessTitle;

  /// No description provided for @staffCreateSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'The staff record is on file.'**
  String get staffCreateSuccessFallback;

  /// No description provided for @staffCreateEmployeeChip.
  ///
  /// In en, this message translates to:
  /// **'Employee: {id}'**
  String staffCreateEmployeeChip(String id);

  /// No description provided for @staffCreateAnotherAction.
  ///
  /// In en, this message translates to:
  /// **'Create another'**
  String get staffCreateAnotherAction;

  /// No description provided for @staffCreateOpenRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Open record'**
  String get staffCreateOpenRecordAction;

  /// No description provided for @staffCreateSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Create staff'**
  String get staffCreateSubmitAction;

  /// No description provided for @staffCreateSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get staffCreateSubmitLoading;

  /// No description provided for @guardianListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get guardianListScreenTitle;

  /// No description provided for @guardianListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone, or email'**
  String get guardianListSearchHint;

  /// No description provided for @guardianListNewGuardianAction.
  ///
  /// In en, this message translates to:
  /// **'New guardian'**
  String get guardianListNewGuardianAction;

  /// No description provided for @guardianListLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading guardians'**
  String get guardianListLoadingTitle;

  /// No description provided for @guardianListLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest roster from the server.'**
  String get guardianListLoadingMessage;

  /// No description provided for @guardianListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No guardians yet'**
  String get guardianListEmptyTitle;

  /// No description provided for @guardianListEmptyFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'No guardians match the current filter'**
  String get guardianListEmptyFilterTitle;

  /// No description provided for @guardianListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first guardian to get started.'**
  String get guardianListEmptyMessage;

  /// No description provided for @guardianListEmptyFilterMessage.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the search or the relation filter.'**
  String get guardianListEmptyFilterMessage;

  /// No description provided for @guardianListAddGuardianAction.
  ///
  /// In en, this message translates to:
  /// **'Add guardian'**
  String get guardianListAddGuardianAction;

  /// No description provided for @guardianListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load guardians'**
  String get guardianListErrorTitle;

  /// No description provided for @guardianListFilterRelation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get guardianListFilterRelation;

  /// No description provided for @guardianListFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get guardianListFilterClear;

  /// No description provided for @guardianListFilterRelationTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by relation'**
  String get guardianListFilterRelationTitle;

  /// No description provided for @guardianListFilterRelationFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get guardianListFilterRelationFather;

  /// No description provided for @guardianListFilterRelationMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get guardianListFilterRelationMother;

  /// No description provided for @guardianListFilterRelationBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get guardianListFilterRelationBrother;

  /// No description provided for @guardianListFilterRelationSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get guardianListFilterRelationSister;

  /// No description provided for @guardianListFilterRelationUncle.
  ///
  /// In en, this message translates to:
  /// **'Uncle'**
  String get guardianListFilterRelationUncle;

  /// No description provided for @guardianListFilterRelationAunt.
  ///
  /// In en, this message translates to:
  /// **'Aunt'**
  String get guardianListFilterRelationAunt;

  /// No description provided for @guardianListFilterRelationGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get guardianListFilterRelationGrandparent;

  /// No description provided for @guardianListFilterRelationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get guardianListFilterRelationOther;

  /// No description provided for @guardianListLinkedChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String guardianListLinkedChip(int count);

  /// No description provided for @guardianDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardianDetailScreenTitle;

  /// No description provided for @guardianDetailLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading guardian'**
  String get guardianDetailLoadingTitle;

  /// No description provided for @guardianDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load guardian'**
  String get guardianDetailErrorTitle;

  /// No description provided for @guardianDetailLinkedHeader.
  ///
  /// In en, this message translates to:
  /// **'Linked students'**
  String get guardianDetailLinkedHeader;

  /// No description provided for @guardianDetailContactHeader.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get guardianDetailContactHeader;

  /// No description provided for @guardianDetailPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get guardianDetailPhoneLabel;

  /// No description provided for @guardianDetailEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get guardianDetailEmailLabel;

  /// No description provided for @guardianDetailOccupationLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get guardianDetailOccupationLabel;

  /// No description provided for @guardianDetailAddressHeader.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get guardianDetailAddressHeader;

  /// No description provided for @guardianDetailAddressLine1Label.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get guardianDetailAddressLine1Label;

  /// No description provided for @guardianDetailAddressLine2Label.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get guardianDetailAddressLine2Label;

  /// No description provided for @guardianDetailCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get guardianDetailCityLabel;

  /// No description provided for @guardianDetailPostalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get guardianDetailPostalCodeLabel;

  /// No description provided for @guardianDetailCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get guardianDetailCountryLabel;

  /// No description provided for @guardianDetailNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get guardianDetailNationalityLabel;

  /// No description provided for @guardianDetailNoDataLabel.
  ///
  /// In en, this message translates to:
  /// **'No data on file.'**
  String get guardianDetailNoDataLabel;

  /// No description provided for @guardianCreateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'New guardian'**
  String get guardianCreateScreenTitle;

  /// No description provided for @guardianCreateLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading form'**
  String get guardianCreateLoadingTitle;

  /// No description provided for @guardianCreateLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the school guardian setup context.'**
  String get guardianCreateLoadingMessage;

  /// No description provided for @guardianCreateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load the form schema'**
  String get guardianCreateErrorTitle;

  /// No description provided for @guardianCreateIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get guardianCreateIdentityHeader;

  /// No description provided for @guardianCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian name'**
  String get guardianCreateNameLabel;

  /// No description provided for @guardianCreateRelationHeader.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get guardianCreateRelationHeader;

  /// No description provided for @guardianCreateRelationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get guardianCreateRelationLabel;

  /// No description provided for @guardianCreateRelationHint.
  ///
  /// In en, this message translates to:
  /// **'Father, Mother, …'**
  String get guardianCreateRelationHint;

  /// No description provided for @guardianCreateContactHeader.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get guardianCreateContactHeader;

  /// No description provided for @guardianCreatePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get guardianCreatePhoneLabel;

  /// No description provided for @guardianCreateEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get guardianCreateEmailLabel;

  /// No description provided for @guardianCreateOccupationLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get guardianCreateOccupationLabel;

  /// No description provided for @guardianCreateAddressHeader.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get guardianCreateAddressHeader;

  /// No description provided for @guardianCreateAddressLine1Label.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get guardianCreateAddressLine1Label;

  /// No description provided for @guardianCreateAddressLine2Label.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get guardianCreateAddressLine2Label;

  /// No description provided for @guardianCreateCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get guardianCreateCityLabel;

  /// No description provided for @guardianCreatePostalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get guardianCreatePostalCodeLabel;

  /// No description provided for @guardianCreateNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get guardianCreateNationalityLabel;

  /// No description provided for @guardianCreateCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get guardianCreateCountryLabel;

  /// No description provided for @guardianCreateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian created'**
  String get guardianCreateSuccessTitle;

  /// No description provided for @guardianCreateSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'The guardian record is on file.'**
  String get guardianCreateSuccessFallback;

  /// No description provided for @guardianCreateAnotherAction.
  ///
  /// In en, this message translates to:
  /// **'Create another'**
  String get guardianCreateAnotherAction;

  /// No description provided for @guardianCreateOpenRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Open record'**
  String get guardianCreateOpenRecordAction;

  /// No description provided for @guardianCreateSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Create guardian'**
  String get guardianCreateSubmitAction;

  /// No description provided for @guardianCreateSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get guardianCreateSubmitLoading;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get commonPrimary;

  /// No description provided for @academicsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Academics'**
  String get academicsScreenTitle;

  /// No description provided for @academicsNewSubjectAction.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get academicsNewSubjectAction;

  /// No description provided for @academicsTabSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get academicsTabSubjects;

  /// No description provided for @academicsTabTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get academicsTabTimetable;

  /// No description provided for @academicsTabBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get academicsTabBranches;

  /// No description provided for @academicsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code, or department'**
  String get academicsSearchHint;

  /// No description provided for @academicsLoadingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Loading subjects'**
  String get academicsLoadingSubjects;

  /// No description provided for @academicsErrorSubjects.
  ///
  /// In en, this message translates to:
  /// **'Could not load subjects'**
  String get academicsErrorSubjects;

  /// No description provided for @academicsEmptySubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get academicsEmptySubjectsTitle;

  /// No description provided for @academicsEmptySubjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first subject to get started.'**
  String get academicsEmptySubjectsMessage;

  /// No description provided for @academicsAddSubjectAction.
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get academicsAddSubjectAction;

  /// No description provided for @academicsLoadingTimetable.
  ///
  /// In en, this message translates to:
  /// **'Loading timetable'**
  String get academicsLoadingTimetable;

  /// No description provided for @academicsErrorTimetable.
  ///
  /// In en, this message translates to:
  /// **'Could not load timetable'**
  String get academicsErrorTimetable;

  /// No description provided for @academicsEmptyTimetableTitle.
  ///
  /// In en, this message translates to:
  /// **'No timetable slots'**
  String get academicsEmptyTimetableTitle;

  /// No description provided for @academicsEmptyTimetableMessage.
  ///
  /// In en, this message translates to:
  /// **'The school has not published any timetable slots yet.'**
  String get academicsEmptyTimetableMessage;

  /// No description provided for @academicsLoadingBranches.
  ///
  /// In en, this message translates to:
  /// **'Loading branches'**
  String get academicsLoadingBranches;

  /// No description provided for @academicsErrorBranches.
  ///
  /// In en, this message translates to:
  /// **'Could not load branches'**
  String get academicsErrorBranches;

  /// No description provided for @academicsEmptyBranchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No branches yet'**
  String get academicsEmptyBranchesTitle;

  /// No description provided for @academicsEmptyBranchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first branch from the school admin console.'**
  String get academicsEmptyBranchesMessage;

  /// No description provided for @subjectCreateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get subjectCreateScreenTitle;

  /// No description provided for @subjectCreateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject created'**
  String get subjectCreateSuccessTitle;

  /// No description provided for @subjectCreateBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back to academics'**
  String get subjectCreateBackAction;

  /// No description provided for @subjectCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subjectCreateNameLabel;

  /// No description provided for @subjectCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mathematics, Arabic, …'**
  String get subjectCreateNameHint;

  /// No description provided for @subjectCreateCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject code'**
  String get subjectCreateCodeLabel;

  /// No description provided for @subjectCreateCodeHint.
  ///
  /// In en, this message translates to:
  /// **'MATH-101'**
  String get subjectCreateCodeHint;

  /// No description provided for @subjectCreateDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get subjectCreateDepartmentLabel;

  /// No description provided for @subjectCreateDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'Sciences, Humanities, …'**
  String get subjectCreateDepartmentHint;

  /// No description provided for @subjectCreateGradeLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade level'**
  String get subjectCreateGradeLevelLabel;

  /// No description provided for @subjectCreateGradeLevelHint.
  ///
  /// In en, this message translates to:
  /// **'Grade 3'**
  String get subjectCreateGradeLevelHint;

  /// No description provided for @subjectCreateCreditHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit hours'**
  String get subjectCreateCreditHoursLabel;

  /// No description provided for @subjectCreateDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get subjectCreateDescriptionLabel;

  /// No description provided for @subjectCreateSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get subjectCreateSubmitAction;

  /// No description provided for @subjectCreateSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get subjectCreateSubmitLoading;

  /// No description provided for @attendanceListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceListScreenTitle;

  /// No description provided for @attendanceListCaptureAction.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get attendanceListCaptureAction;

  /// No description provided for @attendanceListLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading attendance'**
  String get attendanceListLoadingTitle;

  /// No description provided for @attendanceListLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest records from the server.'**
  String get attendanceListLoadingMessage;

  /// No description provided for @attendanceListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get attendanceListEmptyTitle;

  /// No description provided for @attendanceListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap Capture to start the daily attendance for a class group.'**
  String get attendanceListEmptyMessage;

  /// No description provided for @attendanceListStartCaptureAction.
  ///
  /// In en, this message translates to:
  /// **'Start capture'**
  String get attendanceListStartCaptureAction;

  /// No description provided for @attendanceListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance'**
  String get attendanceListErrorTitle;

  /// No description provided for @attendanceListPickClassGroup.
  ///
  /// In en, this message translates to:
  /// **'Pick a class group'**
  String get attendanceListPickClassGroup;

  /// No description provided for @attendanceListClassGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Class group {name}'**
  String attendanceListClassGroupLabel(String name);

  /// No description provided for @attendanceStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get attendanceStatusPresent;

  /// No description provided for @attendanceStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get attendanceStatusAbsent;

  /// No description provided for @attendanceStatusLate.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get attendanceStatusLate;

  /// No description provided for @attendanceStatusExcused.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get attendanceStatusExcused;

  /// No description provided for @attendanceStatusPresentLong.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendanceStatusPresentLong;

  /// No description provided for @attendanceStatusAbsentLong.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceStatusAbsentLong;

  /// No description provided for @attendanceStatusLateLong.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceStatusLateLong;

  /// No description provided for @attendanceStatusExcusedLong.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get attendanceStatusExcusedLong;

  /// No description provided for @attendanceCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance · {classGroup}'**
  String attendanceCaptureTitle(String classGroup);

  /// No description provided for @attendanceCaptureRosterErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load the roster'**
  String get attendanceCaptureRosterErrorTitle;

  /// No description provided for @attendanceCaptureRosterLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading roster'**
  String get attendanceCaptureRosterLoadingTitle;

  /// No description provided for @attendanceCaptureRosterLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the class group from the server.'**
  String get attendanceCaptureRosterLoadingMessage;

  /// No description provided for @attendanceCaptureEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No students in this class group'**
  String get attendanceCaptureEmptyTitle;

  /// No description provided for @attendanceCaptureEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once students are enrolled, attendance capture is enabled.'**
  String get attendanceCaptureEmptyMessage;

  /// No description provided for @attendanceCaptureCountPresent.
  ///
  /// In en, this message translates to:
  /// **'P {count}'**
  String attendanceCaptureCountPresent(int count);

  /// No description provided for @attendanceCaptureCountAbsent.
  ///
  /// In en, this message translates to:
  /// **'A {count}'**
  String attendanceCaptureCountAbsent(int count);

  /// No description provided for @attendanceCaptureCountLate.
  ///
  /// In en, this message translates to:
  /// **'L {count}'**
  String attendanceCaptureCountLate(int count);

  /// No description provided for @attendanceCaptureCountExcused.
  ///
  /// In en, this message translates to:
  /// **'E {count}'**
  String attendanceCaptureCountExcused(int count);

  /// No description provided for @attendanceCaptureMarkAllPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark all present'**
  String get attendanceCaptureMarkAllPresent;

  /// No description provided for @attendanceCaptureMarkAllAbsent.
  ///
  /// In en, this message translates to:
  /// **'Mark all absent'**
  String get attendanceCaptureMarkAllAbsent;

  /// No description provided for @attendanceCaptureSuccessAll.
  ///
  /// In en, this message translates to:
  /// **'Submitted {count, plural, =1{1 record} other{{count} records}} for {date}.'**
  String attendanceCaptureSuccessAll(int count, String date);

  /// No description provided for @attendanceCaptureSuccessPartial.
  ///
  /// In en, this message translates to:
  /// **'Submitted {succeeded}, failed {failed} of {total}.'**
  String attendanceCaptureSuccessPartial(int succeeded, int failed, int total);

  /// No description provided for @attendanceCaptureSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit attendance'**
  String get attendanceCaptureSubmit;

  /// No description provided for @attendanceCaptureResubmit.
  ///
  /// In en, this message translates to:
  /// **'Re-submit'**
  String get attendanceCaptureResubmit;

  /// No description provided for @attendanceCaptureSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get attendanceCaptureSubmitLoading;

  /// No description provided for @attendanceGuardianLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian: {name}'**
  String attendanceGuardianLabel(String name);

  /// No description provided for @examsListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get examsListScreenTitle;

  /// No description provided for @examsListLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading exams'**
  String get examsListLoadingTitle;

  /// No description provided for @examsListLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the published exam plans.'**
  String get examsListLoadingMessage;

  /// No description provided for @examsListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No published exams'**
  String get examsListEmptyTitle;

  /// No description provided for @examsListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When a teacher publishes an exam, it shows up here.'**
  String get examsListEmptyMessage;

  /// No description provided for @examsListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load exams'**
  String get examsListErrorTitle;

  /// No description provided for @examsListStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get examsListStatusOpen;

  /// No description provided for @examsListStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get examsListStatusDraft;

  /// No description provided for @examsListDurationMinutesChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min} other{{minutes} min}}'**
  String examsListDurationMinutesChip(int minutes);

  /// No description provided for @examAttemptScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam attempt'**
  String get examAttemptScreenTitle;

  /// No description provided for @examAttemptAutosaveArmed.
  ///
  /// In en, this message translates to:
  /// **'Autosave armed'**
  String get examAttemptAutosaveArmed;

  /// No description provided for @examAttemptAutosaveSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String examAttemptAutosaveSaved(String time);

  /// No description provided for @examAttemptAutosaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Autosave failed'**
  String get examAttemptAutosaveFailed;

  /// No description provided for @examAttemptEligibilityLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking eligibility'**
  String get examAttemptEligibilityLoadingTitle;

  /// No description provided for @examAttemptEligibilityErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not check eligibility'**
  String get examAttemptEligibilityErrorTitle;

  /// No description provided for @examAttemptIneligibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Not eligible'**
  String get examAttemptIneligibleTitle;

  /// No description provided for @examAttemptIneligibleMessage.
  ///
  /// In en, this message translates to:
  /// **'The server says you cannot take this exam.'**
  String get examAttemptIneligibleMessage;

  /// No description provided for @examAttemptBackToExams.
  ///
  /// In en, this message translates to:
  /// **'Back to exams'**
  String get examAttemptBackToExams;

  /// No description provided for @examAttemptAbandonedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attempt abandoned'**
  String get examAttemptAbandonedTitle;

  /// No description provided for @examAttemptAbandonedMessage.
  ///
  /// In en, this message translates to:
  /// **'You abandoned this attempt. The server marked it as abandoned.'**
  String get examAttemptAbandonedMessage;

  /// No description provided for @examAttemptSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get examAttemptSubmittedTitle;

  /// No description provided for @examAttemptSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your answers are on the server. Check back when the result is published.'**
  String get examAttemptSubmittedMessage;

  /// No description provided for @examAttemptStartErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not start the attempt'**
  String get examAttemptStartErrorTitle;

  /// No description provided for @examAttemptNoStudentError.
  ///
  /// In en, this message translates to:
  /// **'No student resolved. Sign in and retry.'**
  String get examAttemptNoStudentError;

  /// No description provided for @examAttemptReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to start?'**
  String get examAttemptReadyTitle;

  /// No description provided for @examAttemptResolvingStudent.
  ///
  /// In en, this message translates to:
  /// **'Resolving student…'**
  String get examAttemptResolvingStudent;

  /// No description provided for @examAttemptResolveStudentError.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve student: {error}'**
  String examAttemptResolveStudentError(String error);

  /// No description provided for @examAttemptStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Student: {name}'**
  String examAttemptStudentLabel(String name);

  /// No description provided for @examAttemptAutosaveChip.
  ///
  /// In en, this message translates to:
  /// **'Autosave every 15s'**
  String get examAttemptAutosaveChip;

  /// No description provided for @examAttemptResolvingLabel.
  ///
  /// In en, this message translates to:
  /// **'Resolving…'**
  String get examAttemptResolvingLabel;

  /// No description provided for @examAttemptStartAction.
  ///
  /// In en, this message translates to:
  /// **'Start attempt'**
  String get examAttemptStartAction;

  /// No description provided for @examAttemptNoQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions'**
  String get examAttemptNoQuestionsTitle;

  /// No description provided for @examAttemptNoQuestionsMessage.
  ///
  /// In en, this message translates to:
  /// **'The server did not return any questions for this attempt.'**
  String get examAttemptNoQuestionsMessage;

  /// No description provided for @examAttemptAbandon.
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get examAttemptAbandon;

  /// No description provided for @examAttemptAbandoning.
  ///
  /// In en, this message translates to:
  /// **'Abandoning…'**
  String get examAttemptAbandoning;

  /// No description provided for @examAttemptSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit attempt'**
  String get examAttemptSubmit;

  /// No description provided for @examAttemptSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get examAttemptSubmitting;

  /// No description provided for @examAttemptAbandonDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Abandon attempt?'**
  String get examAttemptAbandonDialogTitle;

  /// No description provided for @examAttemptAbandonDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will mark the attempt as abandoned on the server. You cannot resume it.'**
  String get examAttemptAbandonDialogMessage;

  /// No description provided for @examAttemptMarksChip.
  ///
  /// In en, this message translates to:
  /// **'{marks, plural, =1{1 pt} other{{marks} pts}}'**
  String examAttemptMarksChip(int marks);

  /// No description provided for @examAttemptAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer…'**
  String get examAttemptAnswerHint;

  /// No description provided for @gradingCorrectionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct grade'**
  String get gradingCorrectionScreenTitle;

  /// No description provided for @gradingCorrectionLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading form'**
  String get gradingCorrectionLoadingTitle;

  /// No description provided for @gradingCorrectionLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the grade record setup context.'**
  String get gradingCorrectionLoadingMessage;

  /// No description provided for @gradingCorrectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load the form'**
  String get gradingCorrectionErrorTitle;

  /// No description provided for @gradingCorrectionTargetHeader.
  ///
  /// In en, this message translates to:
  /// **'Target grade'**
  String get gradingCorrectionTargetHeader;

  /// No description provided for @gradingCorrectionGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade ID'**
  String get gradingCorrectionGradeLabel;

  /// No description provided for @gradingCorrectionScoresHeader.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get gradingCorrectionScoresHeader;

  /// No description provided for @gradingCorrectionScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get gradingCorrectionScoreLabel;

  /// No description provided for @gradingCorrectionScoreHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get gradingCorrectionScoreHint;

  /// No description provided for @gradingCorrectionMaxScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Max score'**
  String get gradingCorrectionMaxScoreLabel;

  /// No description provided for @gradingCorrectionMaxScoreHint.
  ///
  /// In en, this message translates to:
  /// **'100'**
  String get gradingCorrectionMaxScoreHint;

  /// No description provided for @gradingCorrectionReasonHeader.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get gradingCorrectionReasonHeader;

  /// No description provided for @gradingCorrectionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get gradingCorrectionReasonLabel;

  /// No description provided for @gradingCorrectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this correction needed?'**
  String get gradingCorrectionReasonHint;

  /// No description provided for @gradingCorrectionSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Apply correction'**
  String get gradingCorrectionSubmitAction;

  /// No description provided for @gradingCorrectionSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Applying…'**
  String get gradingCorrectionSubmitLoading;

  /// No description provided for @gradingCorrectionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade corrected'**
  String get gradingCorrectionSuccessTitle;

  /// No description provided for @gradingCorrectionSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'The grade record is on file.'**
  String get gradingCorrectionSuccessFallback;

  /// No description provided for @gradingCorrectionSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {name} corrected'**
  String gradingCorrectionSuccessLabel(String name);

  /// No description provided for @gradingCorrectionScoreChip.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String gradingCorrectionScoreChip(double score);

  /// No description provided for @gradingCorrectionMaxScoreChip.
  ///
  /// In en, this message translates to:
  /// **'Max: {max}'**
  String gradingCorrectionMaxScoreChip(double max);

  /// No description provided for @gradingCorrectionActorChip.
  ///
  /// In en, this message translates to:
  /// **'By {actor}'**
  String gradingCorrectionActorChip(String actor);

  /// No description provided for @gradingCorrectionTimestampLabel.
  ///
  /// In en, this message translates to:
  /// **'Corrected at {timestamp}'**
  String gradingCorrectionTimestampLabel(String timestamp);

  /// No description provided for @gradingCorrectionAnotherAction.
  ///
  /// In en, this message translates to:
  /// **'Correct another'**
  String get gradingCorrectionAnotherAction;

  /// No description provided for @gradingCorrectionBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back to grading'**
  String get gradingCorrectionBackAction;

  /// No description provided for @gradingCorrectionAction.
  ///
  /// In en, this message translates to:
  /// **'Correct a grade'**
  String get gradingCorrectionAction;

  /// No description provided for @gradingCorrectionPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct a grade'**
  String get gradingCorrectionPromptTitle;

  /// No description provided for @gradingCorrectionPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the grade ID (e.g. GR-00001)'**
  String get gradingCorrectionPromptHint;

  /// No description provided for @gradingApprovePolicyAction.
  ///
  /// In en, this message translates to:
  /// **'Approve policy'**
  String get gradingApprovePolicyAction;

  /// No description provided for @gradingApprovePolicySuccess.
  ///
  /// In en, this message translates to:
  /// **'Approved {name}.'**
  String gradingApprovePolicySuccess(String name);

  /// No description provided for @gradingApprovePolicyError.
  ///
  /// In en, this message translates to:
  /// **'Could not approve policy: {message}'**
  String gradingApprovePolicyError(String message);

  /// No description provided for @gradingPromoteAction.
  ///
  /// In en, this message translates to:
  /// **'Promote assessment result'**
  String get gradingPromoteAction;

  /// No description provided for @gradingPromotePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote assessment result'**
  String get gradingPromotePromptTitle;

  /// No description provided for @gradingPromoteResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Assessment result ID'**
  String get gradingPromoteResultLabel;

  /// No description provided for @gradingPromoteResultHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AR-00001'**
  String get gradingPromoteResultHint;

  /// No description provided for @gradingPromotePolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy name'**
  String get gradingPromotePolicyLabel;

  /// No description provided for @gradingPromotePolicyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SGP-MATH-G7'**
  String get gradingPromotePolicyHint;

  /// No description provided for @gradingPromoteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promoted to grade record {id}.'**
  String gradingPromoteSuccess(String id);

  /// No description provided for @gradingPromoteSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'Assessment result promoted.'**
  String get gradingPromoteSuccessFallback;

  /// No description provided for @gradingPromoteError.
  ///
  /// In en, this message translates to:
  /// **'Could not promote: {message}'**
  String gradingPromoteError(String message);

  /// No description provided for @operationsReplayAction.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get operationsReplayAction;

  /// No description provided for @operationsReceiveCallbackAction.
  ///
  /// In en, this message translates to:
  /// **'Receive callback'**
  String get operationsReceiveCallbackAction;

  /// No description provided for @operationsReplayPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay a delivery event'**
  String get operationsReplayPromptTitle;

  /// No description provided for @operationsReplayEventKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Event key'**
  String get operationsReplayEventKeyLabel;

  /// No description provided for @operationsReplayEventKeyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. comm-delivery-2026-08-01-abc'**
  String get operationsReplayEventKeyHint;

  /// No description provided for @operationsReplayReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get operationsReplayReasonLabel;

  /// No description provided for @operationsReplayReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is the replay needed?'**
  String get operationsReplayReasonHint;

  /// No description provided for @operationsReplaySuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Replayed event {key}.'**
  String operationsReplaySuccessSnack(String key);

  /// No description provided for @operationsReplayStatusSnack.
  ///
  /// In en, this message translates to:
  /// **'Replay status: {status}.'**
  String operationsReplayStatusSnack(String status);

  /// No description provided for @operationsReplayErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Replay failed: {message}'**
  String operationsReplayErrorSnack(String message);

  /// No description provided for @operationsReceiveCallbackPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a delivery callback'**
  String get operationsReceiveCallbackPromptTitle;

  /// No description provided for @operationsReceiveCallbackProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get operationsReceiveCallbackProviderLabel;

  /// No description provided for @operationsReceiveCallbackProviderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. stripe / sendgrid / fcm'**
  String get operationsReceiveCallbackProviderHint;

  /// No description provided for @operationsReceiveCallbackSignatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature (optional)'**
  String get operationsReceiveCallbackSignatureLabel;

  /// No description provided for @operationsReceiveCallbackSignatureHint.
  ///
  /// In en, this message translates to:
  /// **'X-Signature header value'**
  String get operationsReceiveCallbackSignatureHint;

  /// No description provided for @operationsReceiveCallbackBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Body (optional)'**
  String get operationsReceiveCallbackBodyLabel;

  /// No description provided for @operationsReceiveCallbackBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Raw callback body (JSON / form)'**
  String get operationsReceiveCallbackBodyHint;

  /// No description provided for @operationsReceiveCallbackSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Callback received for {key}.'**
  String operationsReceiveCallbackSuccessSnack(String key);

  /// No description provided for @operationsReceiveCallbackStatusSnack.
  ///
  /// In en, this message translates to:
  /// **'Callback status: {status}.'**
  String operationsReceiveCallbackStatusSnack(String status);

  /// No description provided for @operationsReceiveCallbackErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Callback failed: {message}'**
  String operationsReceiveCallbackErrorSnack(String message);

  /// No description provided for @privacyRequestSubmitScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a privacy request'**
  String get privacyRequestSubmitScreenTitle;

  /// No description provided for @privacyRequestSubmitTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'Request type'**
  String get privacyRequestSubmitTypeHeader;

  /// No description provided for @privacyRequestTypeAccess.
  ///
  /// In en, this message translates to:
  /// **'Data access'**
  String get privacyRequestTypeAccess;

  /// No description provided for @privacyRequestTypeRectification.
  ///
  /// In en, this message translates to:
  /// **'Rectification'**
  String get privacyRequestTypeRectification;

  /// No description provided for @privacyRequestTypeErasure.
  ///
  /// In en, this message translates to:
  /// **'Erasure'**
  String get privacyRequestTypeErasure;

  /// No description provided for @privacyRequestTypeConsentWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Consent withdrawal'**
  String get privacyRequestTypeConsentWithdrawal;

  /// No description provided for @privacyRequestTypeLegalHold.
  ///
  /// In en, this message translates to:
  /// **'Legal hold'**
  String get privacyRequestTypeLegalHold;

  /// No description provided for @privacyRequestSubmitCategoriesHeader.
  ///
  /// In en, this message translates to:
  /// **'Data categories'**
  String get privacyRequestSubmitCategoriesHeader;

  /// No description provided for @privacyRequestSubmitAuthorityHeader.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get privacyRequestSubmitAuthorityHeader;

  /// No description provided for @privacyRequestSubmitAuthorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Authority reference'**
  String get privacyRequestSubmitAuthorityLabel;

  /// No description provided for @privacyRequestSubmitAuthorityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ticket id or email thread id'**
  String get privacyRequestSubmitAuthorityHint;

  /// No description provided for @privacyRequestSubmitAuthorityRequired.
  ///
  /// In en, this message translates to:
  /// **'An authority reference is required.'**
  String get privacyRequestSubmitAuthorityRequired;

  /// No description provided for @privacyRequestSubmitBranchHeader.
  ///
  /// In en, this message translates to:
  /// **'School branch'**
  String get privacyRequestSubmitBranchHeader;

  /// No description provided for @privacyRequestSubmitBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'School branch'**
  String get privacyRequestSubmitBranchLabel;

  /// No description provided for @privacyRequestSubmitBranchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. main / north / campus-2'**
  String get privacyRequestSubmitBranchHint;

  /// No description provided for @privacyRequestSubmitBranchRequired.
  ///
  /// In en, this message translates to:
  /// **'A school branch is required.'**
  String get privacyRequestSubmitBranchRequired;

  /// No description provided for @privacyRequestSubmitNoteHeader.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get privacyRequestSubmitNoteHeader;

  /// No description provided for @privacyRequestSubmitNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get privacyRequestSubmitNoteLabel;

  /// No description provided for @privacyRequestSubmitNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this request needed?'**
  String get privacyRequestSubmitNoteHint;

  /// No description provided for @privacyRequestSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get privacyRequestSubmitAction;

  /// No description provided for @privacyRequestSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get privacyRequestSubmitLoading;

  /// No description provided for @privacyRequestSubmitSummaryHeader.
  ///
  /// In en, this message translates to:
  /// **'Request context'**
  String get privacyRequestSubmitSummaryHeader;

  /// No description provided for @privacyRequestSubmitSummaryRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester type'**
  String get privacyRequestSubmitSummaryRequester;

  /// No description provided for @privacyRequestSubmitSummarySubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get privacyRequestSubmitSummarySubject;

  /// No description provided for @privacyRequestSubmitSummaryBranch.
  ///
  /// In en, this message translates to:
  /// **'School branch'**
  String get privacyRequestSubmitSummaryBranch;

  /// No description provided for @privacyRequestSubmitSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy request submitted'**
  String get privacyRequestSubmitSuccessTitle;

  /// No description provided for @privacyRequestSubmitSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'The request is on file.'**
  String get privacyRequestSubmitSuccessFallback;

  /// No description provided for @privacyRequestSubmitSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Request {id} submitted.'**
  String privacyRequestSubmitSuccessLabel(String id);

  /// No description provided for @privacyRequestSubmitBackAction.
  ///
  /// In en, this message translates to:
  /// **'Back to my family'**
  String get privacyRequestSubmitBackAction;

  /// No description provided for @privacyRequestCategoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get privacyRequestCategoryPersonal;

  /// No description provided for @privacyRequestCategoryAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get privacyRequestCategoryAttendance;

  /// No description provided for @privacyRequestCategoryGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get privacyRequestCategoryGrades;

  /// No description provided for @privacyRequestCategoryFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get privacyRequestCategoryFees;

  /// No description provided for @privacyRequestCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get privacyRequestCategoryHealth;

  /// No description provided for @privacyRequestCategoryCommunications.
  ///
  /// In en, this message translates to:
  /// **'Communications'**
  String get privacyRequestCategoryCommunications;

  /// No description provided for @governanceApproveSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Approve settings'**
  String get governanceApproveSettingsAction;

  /// No description provided for @governanceApproveSettingsPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve governance settings'**
  String get governanceApproveSettingsPromptTitle;

  /// No description provided for @governanceApproveSettingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy version'**
  String get governanceApproveSettingsVersionLabel;

  /// No description provided for @governanceApproveSettingsVersionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get governanceApproveSettingsVersionHint;

  /// No description provided for @governanceApproveSettingsReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get governanceApproveSettingsReasonLabel;

  /// No description provided for @governanceApproveSettingsReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is the approval needed?'**
  String get governanceApproveSettingsReasonHint;

  /// No description provided for @governanceApproveSettingsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Approved policy version {version}.'**
  String governanceApproveSettingsSuccess(int version);

  /// No description provided for @governanceApproveSettingsSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'Settings approved.'**
  String get governanceApproveSettingsSuccessFallback;

  /// No description provided for @governanceApproveSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Could not approve settings: {message}'**
  String governanceApproveSettingsError(String message);
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
