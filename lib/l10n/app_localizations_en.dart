// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Laratik Schools';

  @override
  String get navStudents => 'Students';

  @override
  String get navStaff => 'Staff';

  @override
  String get navGuardians => 'Guardians';

  @override
  String get navAcademics => 'Academics';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navMyClasses => 'My classes';

  @override
  String get navFees => 'Fees';

  @override
  String get shellDashboard => 'Home';

  @override
  String get shellNotifications => 'Notifications';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonClearSearch => 'Clear search';

  @override
  String get commonNoResults => 'No results';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get homeParentMyChildren => 'My children';

  @override
  String get homeParentNoChildrenTitle => 'No children linked yet';

  @override
  String get homeParentNoChildrenMessage =>
      'When the school links you as a guardian, your children\'s names will appear here. If you expected to see a child and you don\'t, contact the school office to confirm the link is in place.';

  @override
  String get homeParentInbox => 'Inbox';

  @override
  String get homeStudentFeeInvoicesTitle => 'My fee invoices';

  @override
  String get homeStudentFeeInvoicesSubtitle => 'Issued + outstanding plans';

  @override
  String get homeParentPrivacyRequestTitle => 'Submit a privacy request';

  @override
  String get homeParentPrivacyRequestSubtitle =>
      'Data access, erasure, or correction';

  @override
  String get homeStudentPrivacyRequestTitle => 'Submit a privacy request';

  @override
  String get homeStudentPrivacyRequestSubtitle =>
      'Data access, erasure, or correction';

  @override
  String get studentDetailScreenTitle => 'Student';

  @override
  String get studentDetailErrorTitle => 'Could not load student';

  @override
  String get studentDetailLoadingTitle => 'Loading student';

  @override
  String get studentDetailEnrollmentHeader => 'Current enrollment';

  @override
  String get studentDetailIdentityHeader => 'Identity & contact';

  @override
  String get studentDetailGuardiansHeader => 'Guardians';

  @override
  String get studentDetailRecentGradesHeader => 'Recent grades';

  @override
  String get studentDetailGradeLabel => 'Grade';

  @override
  String get studentDetailClassGroupLabel => 'Class group';

  @override
  String get studentDetailAcademicYearLabel => 'Academic year';

  @override
  String get studentDetailStatusLabel => 'Status';

  @override
  String get studentDetailEnrollmentStatusLabel => 'Enrollment status';

  @override
  String get studentDetailActivationLabel => 'Activation';

  @override
  String get studentDetailNationalityLabel => 'Nationality';

  @override
  String get studentDetailCountryLabel => 'Country';

  @override
  String get studentDetailErpnextCustomerLabel => 'ERPNext customer';

  @override
  String get studentDetailNoDataLabel => 'No data on file.';

  @override
  String get studentDetailNoGuardianChip => 'No guardian on file';

  @override
  String get studentDetailCountryWarningTitle => 'Country needs review';

  @override
  String get studentDetailCountryDefaultedMessage =>
      'Country was defaulted from nationality; confirm with the operator.';

  @override
  String get studentDetailCountryMismatchMessage =>
      'Nationality and residential country differ; double-check before grading.';

  @override
  String get studentCreateScreenTitle => 'New student';

  @override
  String get studentCreateLoadingTitle => 'Loading form';

  @override
  String get studentCreateLoadingMessage =>
      'Fetching the school setup context.';

  @override
  String get studentCreateSchemaErrorTitle => 'Could not load the form schema';

  @override
  String get studentCreateSuccessTitle => 'Student created';

  @override
  String get studentCreateSuccessFallback => 'The student record is on file.';

  @override
  String get studentCreateCountryDefaultedChip =>
      'Country defaulted from nationality';

  @override
  String get studentCreateCountryMismatchChip => 'Country ≠ nationality';

  @override
  String studentCreateWarningsChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '1 warning',
    );
    return '$_temp0';
  }

  @override
  String get studentCreateAnotherAction => 'Create another';

  @override
  String get studentCreateOpenRecordAction => 'Open record';

  @override
  String get studentCreateSubmitAction => 'Create student';

  @override
  String get studentCreateSubmitLoading => 'Creating…';

  @override
  String studentCreateRequiredRolesChip(String roles) {
    return 'Requires: $roles';
  }

  @override
  String get studentCreateIdentityHeader => 'Identity';

  @override
  String get studentCreateFirstNameLabel => 'First name';

  @override
  String get studentCreateFirstNameHint =>
      'As it appears on the birth certificate';

  @override
  String get studentCreateLastNameLabel => 'Last name';

  @override
  String get studentCreateDateOfBirthHeader => 'Date of birth';

  @override
  String get studentCreateDateOfBirthLabel => 'Date of birth';

  @override
  String get studentCreateDateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get studentCreateCountryNationalityHeader => 'Country & nationality';

  @override
  String get studentCreateNationalityLabel => 'Nationality';

  @override
  String get studentCreateNationalityHint => 'The nationality on file';

  @override
  String get studentCreateCountryLabel => 'Country of residence';

  @override
  String get studentCreateCountryHint => 'Where the student lives';

  @override
  String get studentCreateGuardianHeader => 'Guardian';

  @override
  String get studentCreateGuardianNameLabel => 'Guardian name';

  @override
  String get studentCreateGuardianPhoneLabel => 'Guardian phone';

  @override
  String get studentCreateEnrollmentHeader => 'Enrollment';

  @override
  String get studentCreateGradeLabel => 'Grade';

  @override
  String get studentCreateGradeHint => 'Grade 1';

  @override
  String get studentCreateNotesHeader => 'Notes';

  @override
  String get studentCreateNotesLabel => 'Notes';

  @override
  String get homeParentInboxEmpty => 'No new messages';

  @override
  String homeParentInboxUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
      zero: 'No new messages',
    );
    return '$_temp0';
  }

  @override
  String get homeStudentMySchool => 'My school';

  @override
  String homeStudentGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String homeStudentStudentId(String id) {
    return 'Student ID: $id';
  }

  @override
  String get homeStudentResolving => 'Resolving student…';

  @override
  String get homeStudentResolvingMessage =>
      'Looking up the active student for this device.';

  @override
  String get homeStudentResolvingFailed => 'Student resolution failed';

  @override
  String get homeStudentNoStudent => 'No student resolved';

  @override
  String get homeStudentNoStudentMessage =>
      'No students are seeded on this site yet.';

  @override
  String get homeStudentSwitchStudent => 'Switch student';

  @override
  String get homeStudentToday => 'Today';

  @override
  String get homeStudentMore => 'More';

  @override
  String get homeStudentAllExams => 'All exams';

  @override
  String get homeStudentAllExamsSubtitle => 'Browse every published exam';

  @override
  String get homeStudentMyRecords => 'My records';

  @override
  String get homeStudentMyRecordsSubtitle =>
      'Grades, attendance, and report cards';

  @override
  String get homeStudentNoExamsTitle => 'No exams today';

  @override
  String get homeStudentNoExamsMessage =>
      'You have no published exam plans waiting for you. New exams will appear here as teachers publish them.';

  @override
  String get homeStudentLoadingExamsTitle => 'Loading exams';

  @override
  String get homeStudentLoadingExamsMessage =>
      'Fetching your published exam catalog.';

  @override
  String get homeStudentCouldNotLoadExams => 'Could not load exams';

  @override
  String get homeStudentTakeNextExam => 'Take your next exam';

  @override
  String get homeStudentOpenExam => 'Open exam';

  @override
  String get homeStudentInboxSubtitle => 'Inbox + announcements';

  @override
  String get homeParentMyFamily => 'My family';

  @override
  String get homeParentFeeInvoicesTitle => 'Fee invoices';

  @override
  String get homeParentFeeInvoicesSubtitle =>
      'Review your children\'s fee plans and payment status.';

  @override
  String get homeParentHeroLoadingMessage =>
      'Looking up the students you are linked to.';

  @override
  String get homeParentHeroLoadingChip => 'Loading…';

  @override
  String get homeParentHeroErrorMessage =>
      'We couldn\'t load your children just now. Tap to retry.';

  @override
  String get homeParentHeroErrorChip => 'Try again';

  @override
  String homeParentLinkedChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked children',
      one: '1 linked child',
      zero: 'No linked children',
    );
    return '$_temp0';
  }

  @override
  String homeParentLinkedChildrenActive(int count, int active) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count linked children · $active active. Tap to see grades, attendance, and report cards.',
      one: '1 linked child · tap to see grades, attendance, and report cards.',
    );
    return '$_temp0';
  }

  @override
  String get homeTeacherMySchool => 'My school';

  @override
  String get homeTeacherMyClasses => 'My classes';

  @override
  String get homeTeacherCaptureAttendance => 'Capture attendance';

  @override
  String get homeTeacherCaptureAttendanceSubtitle => 'Mark a class group';

  @override
  String get homeTeacherInboxSubtitle => 'Inbox + announcements';

  @override
  String get homeTeacherQuickStart => 'Quick start';

  @override
  String get homeTeacherHeroLoadingMessage =>
      'Looking up the (class, subject) pairs you teach.';

  @override
  String get homeTeacherHeroLoadingChip => 'Loading…';

  @override
  String get homeTeacherHeroErrorMessage =>
      'We couldn\'t load your classes just now. Tap to retry.';

  @override
  String get homeTeacherHeroErrorChip => 'Try again';

  @override
  String homeTeacherHeroActive(int count, int active) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count teaching assignments · $active active. Tap to see your roster + exams for that subject.',
      one:
          '1 teaching assignment · tap to see your roster + exams for that subject.',
    );
    return '$_temp0';
  }

  @override
  String get homeTeacherHeroEmpty =>
      'When the registrar assigns you to a (class, subject) pair, the class will appear here.';

  @override
  String get homeAdminMyHome => 'Home';

  @override
  String homeAdminActingAs(String name) {
    return 'Acting as: $name';
  }

  @override
  String homeAdminSignedInAs(String role) {
    return 'Signed in as: $role';
  }

  @override
  String get homeAdminQuickStart => 'Quick start';

  @override
  String get homeAdminPracticeQuiz => 'Practice quiz';

  @override
  String get homeAdminPracticeQuizSubtitle => 'Take a published exam';

  @override
  String get homeAdminNewStudent => 'New student';

  @override
  String get homeAdminNewStudentSubtitle => 'Enrol from the registrar';

  @override
  String get homeAdminNewStaff => 'New staff';

  @override
  String get homeAdminNewStaffSubtitle => 'Add a teacher or admin';

  @override
  String get homeAdminNewSubject => 'New subject';

  @override
  String get homeAdminNewSubjectSubtitle => 'Add a subject to the catalog';

  @override
  String get homeAdminCaptureAttendance => 'Capture attendance';

  @override
  String get homeAdminCaptureAttendanceSubtitle => 'Mark a class group';

  @override
  String get homeAdminFeePlans => 'Fee plans';

  @override
  String get homeAdminFeePlansSubtitle => 'Review issued + outstanding plans';

  @override
  String get homeAdminFeeOperations => 'Fee operations';

  @override
  String get homeAdminFeeOperationsSubtitle =>
      'Invoiced / collected / outstanding';

  @override
  String get homeAdminOperations => 'Operations';

  @override
  String get homeAdminOperationsSubtitle =>
      'System health, delivery, audit log';

  @override
  String get homeAdminGovernance => 'Governance';

  @override
  String get homeAdminGovernanceSubtitle =>
      'Privacy requests, legal hold, retention';

  @override
  String get homeAdminGrading => 'Grading';

  @override
  String get homeAdminGradingSubtitle =>
      'Overview, policies, per-record review';

  @override
  String get homeAdminNotificationsSubtitle => 'Inbox + announcements';

  @override
  String myChildrenHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked children',
      one: '1 linked child',
      zero: 'No linked children',
    );
    return '$_temp0';
  }

  @override
  String myChildrenHeaderActive(int active, int inactive) {
    return '$active active · $inactive withdrawn. Withdrawn links are kept for reference.';
  }

  @override
  String get myChildrenHeaderAllActive =>
      'Tap a child to see their grades, attendance, and report cards.';

  @override
  String get myChildrenChildCurrent => 'Current';

  @override
  String get myChildrenChildActive => 'Active';

  @override
  String get meSwitchStudentTitle => 'Switch student';

  @override
  String get meSwitchStudentSearch => 'Search by name or student number';

  @override
  String meSwitchStudentNoResultsTitle(String query) {
    return 'No students match \"$query\"';
  }

  @override
  String get meSwitchStudentEmptyTitle => 'No students yet';

  @override
  String get meSwitchStudentEmptyMessage =>
      'Add a student to the roster, then come back here to pick one.';

  @override
  String get meSwitchStudentSearchingTitle => 'Searching students';

  @override
  String get meSwitchStudentSearchingMessage => 'Looking up the roster.';

  @override
  String meSwitchStudentNowActingAs(String name) {
    return 'Now acting as $name';
  }

  @override
  String myClassesHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active assignments',
      one: '1 active assignment',
      zero: 'No active assignments',
    );
    return '$_temp0';
  }

  @override
  String myClassesHeaderActive(int active, int inactive) {
    return '$active active · $inactive inactive. Inactive assignments are kept for reference.';
  }

  @override
  String get myClassesHeaderAllActive =>
      'Tap a class to see your roster + exams for that subject.';

  @override
  String get myClassesEmptyTitle => 'No classes assigned';

  @override
  String get myClassesEmptyMessage =>
      'You don\'t have any active teaching assignments yet. When the registrar assigns you to a (class, subject) pair, the class will appear here.';

  @override
  String get myClassesLoadingTitle => 'Loading your classes';

  @override
  String get myClassesLoadingMessage =>
      'Looking up the (class, subject) pairs you teach.';

  @override
  String get myClassesChipHomeroom => 'Homeroom';

  @override
  String get classDetailRosterTitle => 'Loading roster';

  @override
  String get classDetailRosterMessage =>
      'Looking up the students assigned to this class group.';

  @override
  String get classDetailRosterEmptyTitle => 'No students in this class yet';

  @override
  String get classDetailRosterEmptyMessage =>
      'No students are assigned to this class group yet. When the registrar enrols students, they will appear here automatically.';

  @override
  String get classDetailHeaderClassGroup => 'Class group';

  @override
  String get childDetailTitleOwn => 'My records';

  @override
  String get childDetailTitleOther => 'Child';

  @override
  String get childDetailTabOverview => 'Overview';

  @override
  String get childDetailTabGrades => 'Grades';

  @override
  String get childDetailTabAttendance => 'Attendance';

  @override
  String get childDetailTabReports => 'Report cards';

  @override
  String get childDetailOverviewKpiGrades => 'Grades';

  @override
  String get childDetailOverviewKpiAverage => 'Average';

  @override
  String get childDetailOverviewKpiAttendance => 'Attendance';

  @override
  String get childDetailOverviewKpiReports => 'Report cards';

  @override
  String get childDetailOverviewMessageOwn =>
      'A quick summary of your grades, attendance, and report cards. Open a tab above for the full list.';

  @override
  String get childDetailOverviewMessageOther =>
      'A quick summary of this child\'s grades, attendance, and report cards. Open a tab above for the full list.';

  @override
  String get childDetailOverviewTitleOwn => 'Your records at a glance';

  @override
  String get childDetailOverviewTitleOther => 'At a glance';

  @override
  String get childDetailGradesEmptyTitle => 'No grades yet';

  @override
  String get childDetailGradesEmptyMessage =>
      'No published grades for this student yet. New grades appear here as soon as teachers release them.';

  @override
  String get childDetailAttendanceEmptyTitle => 'No attendance recorded';

  @override
  String get childDetailAttendanceEmptyMessage =>
      'No attendance has been recorded for this student yet. Daily attendance will appear here as it\'s captured.';

  @override
  String get childDetailReportsEmptyTitle => 'No report cards yet';

  @override
  String get childDetailReportsEmptyMessage =>
      'No report cards have been published for this student yet. Term summaries appear here once the school releases them.';

  @override
  String get childDetailEmptyStateFallback => 'Could not load records';

  @override
  String get childDetailNoStudentTitle => 'No student resolved for this device';

  @override
  String get childDetailNoStudentMessage =>
      'We couldn\'t resolve the student this device is acting as. Sign out and back in, or contact the school office if the issue persists.';

  @override
  String feePlansHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fee plans',
      one: '1 fee plan',
      zero: 'No fee plans',
    );
    return '$_temp0';
  }

  @override
  String get feePlansEmptyTitle => 'No fee plans yet';

  @override
  String get feePlansEmptyMessage =>
      'You don\'t have any active fee plans yet. When the school issues a plan for your child, it will appear here with the per-line breakdown and a payment status.';

  @override
  String get feePlansLoadingTitle => 'Loading fee plans';

  @override
  String get feePlansLoadingMessage =>
      'Looking up the latest fee plans from the server.';

  @override
  String get feePlansBreakdown => 'Breakdown';

  @override
  String get a11yRefreshTooltip => 'Refresh';

  @override
  String get a11yNotificationsTooltip => 'Notifications';

  @override
  String get a11ySwitchStudentTooltip => 'Switch student';

  @override
  String a11yActingAs(String name) {
    return 'Acting as $name';
  }

  @override
  String a11yUnreadNotifications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
      zero: 'No unread messages',
    );
    return '$_temp0';
  }

  @override
  String get familyHomeLoadingTitle => 'Loading your children';

  @override
  String get familyHomeErrorTitle => 'Could not load your children';

  @override
  String familyChildRowRelation(String relation) {
    return 'as $relation';
  }

  @override
  String familyChildRowId(String code) {
    return 'ID $code';
  }

  @override
  String get childDetailLoadingTitle => 'Loading records';

  @override
  String get childDetailLoadingMessage =>
      'Pulling grades, attendance, and report cards.';

  @override
  String get childDetailGradeAssessmentFallback => 'Assessment';

  @override
  String get childDetailGradePass => 'Pass';

  @override
  String get childDetailGradeFail => 'Fail';

  @override
  String childDetailGradePublishedOn(String date) {
    return 'Published $date';
  }

  @override
  String get childDetailReportCardFallback => 'Report card';

  @override
  String get childDetailAverageOnTrack => 'On track';

  @override
  String get childDetailAverageBelowTarget => 'Below target';

  @override
  String get childDetailAverageNoGrades => 'No grades yet';

  @override
  String get childDetailGradesAllPassed => 'All passed';

  @override
  String childDetailGradesOfTotalPassed(int passed, int total) {
    return '$passed of $total passed';
  }

  @override
  String get childDetailAttendanceNoAbsences => 'No absences';

  @override
  String childDetailAttendanceKpiSub(int present, int absent) {
    return '$present present · $absent absent';
  }

  @override
  String childDetailAttendanceKpiSubLate(int present, int absent, int late) {
    return '$present present · $absent absent · $late late';
  }

  @override
  String get childDetailReportCardNoCards => 'No cards yet';

  @override
  String childDetailReportCardLatest(String label) {
    return 'Latest: $label';
  }

  @override
  String get meSwitchStudentErrorTitle => 'Could not load students';

  @override
  String get meSwitchStudentNoResultsMessage =>
      'Try a shorter search, or clear the search to see the full roster.';

  @override
  String get myClassesErrorTitle => 'Could not load your classes';

  @override
  String myClassesAcademicYear(String year) {
    return 'Academic year $year';
  }

  @override
  String get classDetailTitle => 'Class';

  @override
  String get classDetailErrorTitle => 'Could not load roster';

  @override
  String classDetailStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get feePlansScreenTitle => 'Fee plans';

  @override
  String get feePlansErrorTitle => 'Could not load fee plans';

  @override
  String feePlansOverdueChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String feePlansPartialChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partial',
      one: '1 partial',
    );
    return '$_temp0';
  }

  @override
  String feePlansPaidChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paid',
      one: '1 paid',
    );
    return '$_temp0';
  }

  @override
  String feePlansAmountLine(String currency, String total, String outstanding) {
    return '$currency $total total · outstanding $currency $outstanding';
  }

  @override
  String feePlansAmountOnly(String currency, String total) {
    return '$currency $total';
  }

  @override
  String get feePlanDetailTitle => 'Fee plan';

  @override
  String get feePlanLoadingTitle => 'Loading fee plan';

  @override
  String get feePlanLoadingMessage =>
      'Looking up the per-line breakdown and payment status.';

  @override
  String get feePlanErrorTitle => 'Could not load fee plan';

  @override
  String get feePlanNotFoundTitle => 'Fee plan not found';

  @override
  String get feePlanNotFoundMessage =>
      'We couldn\'t find this fee plan in the current catalog. It may have been cancelled or moved to a different academic year; head back to the list to see the latest plans.';

  @override
  String get feePlanNotFoundAction => 'Back to fee plans';

  @override
  String get feePlanNoBreakdownMessage =>
      'The server didn\'t return a per-line breakdown for this plan. The total amount is shown above; the itemized list lands when the plan is itemized on the server side.';

  @override
  String feePlanIdentitySubtitle(String id) {
    return 'Fee plan $id';
  }

  @override
  String feePlanDueDateChip(String date) {
    return 'Due $date';
  }

  @override
  String get feePlanTotalLabel => 'Total';

  @override
  String get feePlanPaidLabel => 'Paid';

  @override
  String get feePlanOutstandingLabel => 'Outstanding';

  @override
  String get feeOperationsScreenTitle => 'Fee operations';

  @override
  String get feeOperationsLoadingTitle => 'Loading operations';

  @override
  String get feeOperationsLoadingMessage =>
      'Aggregating the latest invoice + payment totals.';

  @override
  String get feeOperationsErrorTitle => 'Could not load operations';

  @override
  String get feeOperationsCollectionRate => 'Collection rate';

  @override
  String get feeOperationsNoInvoices => 'No invoices yet';

  @override
  String get feeOperationsNoInvoicesMessage =>
      'The school hasn\'t issued any invoices yet. The rate will appear as soon as the first plan is published.';

  @override
  String feeOperationsCollectedOfTotal(String collectedCurrency,
      String collectedAmount, String totalCurrency, String totalAmount) {
    return '$collectedCurrency $collectedAmount of $totalCurrency $totalAmount collected so far.';
  }

  @override
  String get feeOperationsInvoiced => 'Invoiced';

  @override
  String get feeOperationsInvoicedSub => 'Total issued this period';

  @override
  String get feeOperationsCollected => 'Collected';

  @override
  String get feeOperationsCollectedSub => 'Total received so far';

  @override
  String get feeOperationsOutstanding => 'Outstanding';

  @override
  String get feeOperationsOutstandingSub => 'Still due';

  @override
  String get feeOperationsByStatus => 'By status';

  @override
  String feeOperationsPaidCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paid',
      one: '1 paid',
    );
    return '$_temp0';
  }

  @override
  String feeOperationsOverdueCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String feeOperationsDraftCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count draft',
      one: '1 draft',
    );
    return '$_temp0';
  }

  @override
  String get feeOperationsViewPlansAction => 'View fee plans';

  @override
  String get operationsScreenTitle => 'Operations';

  @override
  String get operationsTabHealth => 'Health';

  @override
  String get operationsTabDelivery => 'Delivery';

  @override
  String get operationsTabAudit => 'Audit';

  @override
  String get operationsLoadingTitle => 'Loading operations health';

  @override
  String get operationsLoadingMessage =>
      'Aggregating the latest per-module KPI snapshot.';

  @override
  String get operationsErrorTitle => 'Could not load operations';

  @override
  String get operationsSystemHealth => 'System health';

  @override
  String get operationsStatusHealthy => 'Healthy';

  @override
  String get operationsStatusDegraded => 'Degraded';

  @override
  String get operationsStatusUnhealthy => 'Unhealthy';

  @override
  String operationsGeneratedAt(String timestamp) {
    return 'Generated at $timestamp';
  }

  @override
  String get operationsModulesHeader => 'Per-module KPIs';

  @override
  String get operationsModulesEmptyTitle => 'No module KPIs yet';

  @override
  String get operationsModulesEmptyMessage =>
      'The server hasn\'t reported any per-module metrics. They\'ll appear here as soon as the first snapshot lands.';

  @override
  String get operationsModuleAnalytics => 'Analytics';

  @override
  String get operationsModuleAudit => 'Audit';

  @override
  String get operationsModuleDelivery => 'Delivery';

  @override
  String get operationsModuleImports => 'Imports';

  @override
  String get operationsModuleOutbox => 'Outbox';

  @override
  String get operationsDeliveryLoadingTitle => 'Loading delivery health';

  @override
  String get operationsDeliveryLoadingMessage =>
      'Aggregating the per-status delivery counts.';

  @override
  String get operationsDeliveryByStatus => 'By status';

  @override
  String get operationsDeliveryEmptyTitle => 'No deliveries yet';

  @override
  String get operationsDeliveryEmptyMessage =>
      'The delivery queue is empty. Counts will appear here as soon as the server starts dispatching events.';

  @override
  String get operationsDeliveryTotal => 'Total deliveries';

  @override
  String get operationsDeliveryTotalSubtitle =>
      'Across all statuses for this period';

  @override
  String get operationsAuditLoadingTitle => 'Loading audit events';

  @override
  String get operationsAuditLoadingMessage =>
      'Fetching the most recent login / logout / token / device events.';

  @override
  String get operationsAuditEmptyTitle => 'No audit events yet';

  @override
  String get operationsAuditEmptyMessage =>
      'The auth audit log is empty. Events will appear here as the school uses the mobile app.';

  @override
  String get operationsAuditUnknownUser => 'Unknown user';

  @override
  String operationsAuditFromIp(String ip) {
    return 'From $ip';
  }

  @override
  String get governanceScreenTitle => 'Governance';

  @override
  String get governanceLoadingTitle => 'Loading privacy requests';

  @override
  String get governanceLoadingMessage =>
      'Aggregating the latest privacy + legal hold queue.';

  @override
  String get governanceErrorTitle => 'Could not load privacy requests';

  @override
  String get governanceEmptyTitle => 'No privacy requests';

  @override
  String get governanceEmptyMessage =>
      'The queue is empty. When a parent or staff member submits a request (data export / deletion / consent / legal hold), it\'ll appear here for review.';

  @override
  String governanceQueueHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count privacy requests',
      one: '1 privacy request',
      zero: 'No requests',
    );
    return '$_temp0';
  }

  @override
  String governanceLegalHoldCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count under legal hold',
      one: '1 under legal hold',
    );
    return '$_temp0';
  }

  @override
  String get governanceLegalHoldChip => 'Legal hold';

  @override
  String get governanceUnknownSubject => 'Unknown subject';

  @override
  String get governanceActionsTitle => 'Request actions';

  @override
  String get governanceActionProcess => 'Mark as in review';

  @override
  String get governanceActionProcessDescription =>
      'Move this request to \"Under Review\" so the team knows it\'s being worked on.';

  @override
  String get governanceActionApprove => 'Approve request';

  @override
  String get governanceActionApproveDescription =>
      'Approve this request. The requester will be notified and the action is logged.';

  @override
  String get governanceActionSetHold => 'Set legal hold';

  @override
  String get governanceActionSetHoldDescription =>
      'Place this request under a legal hold. The data is preserved until the hold is released.';

  @override
  String get governanceActionReleaseHold => 'Release legal hold';

  @override
  String get governanceActionReleaseHoldDescription =>
      'Release the legal hold. The request can then be approved or rejected.';

  @override
  String get governanceActionSuccess => 'Action applied.';

  @override
  String get governanceEvaluateRetentionTooltip => 'Run retention evaluation';

  @override
  String get governanceEvaluateRetentionSuccess =>
      'Retention evaluation started.';

  @override
  String get governanceEvaluateRetentionFailure =>
      'Could not start retention evaluation.';

  @override
  String get gradingScreenTitle => 'Grading';

  @override
  String get gradingTabOverview => 'Overview';

  @override
  String get gradingTabPolicies => 'Policies';

  @override
  String get gradingLoadingTitle => 'Loading grading data';

  @override
  String get gradingLoadingMessage =>
      'Aggregating the latest grade records + policy catalog.';

  @override
  String get gradingErrorTitle => 'Could not load grading data';

  @override
  String get gradingKpiTotal => 'Total grades';

  @override
  String get gradingKpiTotalSubtitle => 'All grade records (published + draft)';

  @override
  String get gradingKpiPublished => 'Published';

  @override
  String get gradingKpiPublishedSubtitle => 'Promoted to a grade record';

  @override
  String get gradingKpiDraft => 'Draft';

  @override
  String get gradingKpiDraftSubtitle => 'Still pending publish';

  @override
  String get gradingKpiAverage => 'Average';

  @override
  String get gradingKpiAverageSubtitle => 'School-wide published average';

  @override
  String get gradingWorkflowHeader => 'Workflow';

  @override
  String get gradingFeatureHeader => 'Feature';

  @override
  String gradingFeatureValue(String feature) {
    return 'Feature: $feature';
  }

  @override
  String gradingCoverageValue(String coverage) {
    return 'Coverage: $coverage';
  }

  @override
  String gradingRecentStudentsValue(String value) {
    return 'Recent students: $value';
  }

  @override
  String gradingPassThresholdValue(String pct) {
    return 'Pass ≥ $pct%';
  }

  @override
  String get gradingPermissionsHeader => 'Permissions';

  @override
  String gradingPermissionsDoctypesValue(String doctypes) {
    return 'Manages: $doctypes';
  }

  @override
  String get gradingPermissionsReadRoles => 'Read roles';

  @override
  String get gradingPermissionsRequiredRoles => 'Required roles for approval';

  @override
  String get loginScreenTitle => 'Laratik Schools';

  @override
  String get loginSignInSubtitle => 'Sign in to continue';

  @override
  String get loginOAuthPkceTitle => 'OAuth + PKCE';

  @override
  String get loginOAuthPkceMessage =>
      'S256, in-app webview, system-broker redirect.';

  @override
  String get loginSsoChip => 'Laratik SSO';

  @override
  String get loginButton => 'Sign in with Laratik';

  @override
  String get loginButtonLoading => 'Opening browser…';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUnread => 'Unread';

  @override
  String get notificationsLoadingTitle => 'Loading notifications';

  @override
  String get notificationsLoadingMessage =>
      'Fetching the latest inbox from the server.';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyMessage => 'You are all caught up.';

  @override
  String get notificationsErrorTitle => 'Could not load notifications';

  @override
  String get studentsTitle => 'Students';

  @override
  String get studentsNewButton => 'New student';

  @override
  String get studentsSearchPlaceholder => 'Search by name or student number';

  @override
  String get studentsFilterByGrade => 'Filter by grade';

  @override
  String get studentsFilterByClassGroup => 'Filter by class group';

  @override
  String get studentsGradeFilterChip => 'Grade';

  @override
  String get studentsClassGroupFilterChip => 'Class group';

  @override
  String get studentsFilterClear => 'Clear';

  @override
  String get studentsFilterApply => 'Apply';

  @override
  String get studentsLoadingTitle => 'Loading students';

  @override
  String get studentsLoadingMessage =>
      'Fetching the latest roster from the server.';

  @override
  String get studentsEmptyTitle => 'No students yet';

  @override
  String get studentsEmptyMessage =>
      'When you add a student to the roster, they will appear here.';

  @override
  String get studentsNoMatchTitle => 'No students match the current filter';

  @override
  String get studentsNoMatchMessage =>
      'Try clearing the search or the grade filter.';

  @override
  String get studentsErrorTitle => 'Could not load students';

  @override
  String get studentsAddStudentButton => 'Add student';

  @override
  String get studentsFirstStudentMessage =>
      'Add the first student to get started.';

  @override
  String get dataImportsScreenTitle => 'Data imports';

  @override
  String get dataImportsTabBatches => 'Batches';

  @override
  String get dataImportsTabScoreImports => 'Score imports';

  @override
  String get dataImportsLoadingTitle => 'Loading data imports';

  @override
  String get dataImportsLoadingMessage =>
      'Fetching the latest batches + score imports from the server.';

  @override
  String get dataImportsErrorTitle => 'Could not load data imports';

  @override
  String get dataImportsBatchesEmptyTitle => 'No data import batches yet';

  @override
  String get dataImportsBatchesEmptyMessage =>
      'When a package is uploaded (via the desktop or the future mobile wizard), it will appear here.';

  @override
  String get dataImportsScoreEmptyTitle => 'No score imports yet';

  @override
  String get dataImportsScoreEmptyMessage =>
      'When a score file is uploaded (via the desktop or the future mobile wizard), it will appear here.';

  @override
  String dataImportsHashChip(String hash) {
    return 'Hash $hash';
  }

  @override
  String dataImportsRowCountChip(String doctype, int count) {
    return '$doctype · $count';
  }

  @override
  String dataImportsBatchCreatedAt(String when) {
    return 'Submitted $when';
  }

  @override
  String dataImportsScoreCreatedAt(String when) {
    return 'Submitted $when';
  }

  @override
  String get dataImportsBatchDetailTitle => 'Batch reconciliation';

  @override
  String get dataImportsBatchFallbackHeader => 'Loading batch summary…';

  @override
  String dataImportsReconciliationHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
      zero: 'No rows',
    );
    return '$_temp0';
  }

  @override
  String get dataImportsReconciliationEmptyTitle => 'No reconciliation rows';

  @override
  String get dataImportsReconciliationEmptyMessage =>
      'This batch has no per-row decisions to review.';

  @override
  String get dataImportsReconciliationDoctypeFallback => 'Untyped row';

  @override
  String dataImportsReconciliationRowIndex(int index) {
    return 'Row $index';
  }

  @override
  String dataImportsPayloadChip(String key, String value) {
    return '$key · $value';
  }

  @override
  String get dataImportsScoreDetailTitle => 'Score import';

  @override
  String get dataImportsScoreNotFoundTitle => 'Score import not found';

  @override
  String get dataImportsScoreNotFoundMessage =>
      'This score import is no longer in the school\'s catalog.';

  @override
  String dataImportsScoreColumnsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columns',
      one: '1 column',
      zero: 'No columns',
    );
    return '$_temp0';
  }

  @override
  String dataImportsScoreColumnChip(String source, String target) {
    return '$source → $target';
  }

  @override
  String dataImportsScoreColumnsChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columns',
      one: '1 column',
    );
    return '$_temp0';
  }

  @override
  String get dataImportsScoreCountsHeader => 'Validate counts';

  @override
  String dataImportsScoreCountChip(String key, String value) {
    return '$key · $value';
  }

  @override
  String get dataImportsScoreValidateAction => 'Validate';

  @override
  String get dataImportsScoreCommitAction => 'Commit';

  @override
  String get dataImportsScoreValidatedSnack => 'Score import validated.';

  @override
  String get dataImportsScoreCommittedSnack => 'Score import committed.';

  @override
  String dataImportsScoreErrorSnack(String message) {
    return 'Action failed: $message';
  }

  @override
  String get homeAdminDataImports => 'Data imports';

  @override
  String get homeAdminDataImportsSubtitle => 'Review batches + score imports';

  @override
  String get homeTeacherExams => 'Exams';

  @override
  String get homeTeacherExamsSubtitle => 'Author exam plans + grade attempts';

  @override
  String get teacherExamsScreenTitle => 'Exams';

  @override
  String get teacherExamsLoadingTitle => 'Loading exams';

  @override
  String get teacherExamsLoadingMessage =>
      'Fetching your exam plans from the server.';

  @override
  String get teacherExamsErrorTitle => 'Could not load exams';

  @override
  String get teacherExamsEmptyTitle => 'No exam plans yet';

  @override
  String get teacherExamsEmptyMessage =>
      'When you author an exam, it will appear here.';

  @override
  String teacherExamsDurationChip(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String teacherExamsMaxScoreChip(int score) {
    return 'Max $score';
  }

  @override
  String get teacherExamDetailTitle => 'Exam plan';

  @override
  String get teacherExamNotFoundTitle => 'Exam plan not found';

  @override
  String get teacherExamNotFoundMessage =>
      'This exam plan is no longer in the school\'s catalog.';

  @override
  String get teacherExamStatusPublished => 'Published';

  @override
  String get teacherExamStatusClosed => 'Closed';

  @override
  String get teacherExamStatusDraft => 'Draft';

  @override
  String teacherExamDateChip(String date) {
    return 'Date $date';
  }

  @override
  String teacherExamMarksChip(int marks) {
    String _temp0 = intl.Intl.pluralLogic(
      marks,
      locale: localeName,
      other: '$marks marks',
      one: '1 mark',
    );
    return '$_temp0';
  }

  @override
  String get teacherExamQuestionsHeader => 'Questions';

  @override
  String get teacherExamQuestionsEmptyTitle => 'No questions';

  @override
  String get teacherExamQuestionsEmptyMessage =>
      'The subject\'s question catalog is empty. Add questions via the desktop, or the future mobile wizard.';

  @override
  String get teacherExamQuestionFallback => 'Untitled question';

  @override
  String teacherExamQuestionTypeChip(String type) {
    return 'Type: $type';
  }

  @override
  String get teacherExamManualGradeAction => 'Manual grade entry';

  @override
  String get manualGradeScreenTitle => 'Manual grade';

  @override
  String get manualGradeAttemptHeader => 'Attempt';

  @override
  String get manualGradeAttemptLabel => 'Attempt ID';

  @override
  String get manualGradeAttemptHint =>
      'Paste the attempt ID from a notification or the desktop';

  @override
  String get manualGradeAttemptRequired => 'Attempt ID is required';

  @override
  String manualGradeScoresHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
      zero: 'No questions',
    );
    return '$_temp0';
  }

  @override
  String get manualGradeScoresEmptyTitle => 'No questions';

  @override
  String get manualGradeScoresEmptyMessage =>
      'Add questions to this plan first.';

  @override
  String get manualGradeScoreLabel => 'Score';

  @override
  String manualGradeScoreHint(int max) {
    return '0 – $max';
  }

  @override
  String get manualGradeScoreRequired => 'Score is required';

  @override
  String get manualGradeScoreInvalid => 'Enter a valid number';

  @override
  String get manualGradeScoreNegative => 'Score cannot be negative';

  @override
  String manualGradeScoreOverMax(int max) {
    return 'Score cannot exceed $max';
  }

  @override
  String get manualGradeSubmitAction => 'Submit grade';

  @override
  String get manualGradeSubmitLoading => 'Submitting…';

  @override
  String manualGradeSuccessSnack(double score) {
    return 'Attempt graded. New total score: $score';
  }

  @override
  String get manualGradeSuccessSnackNoScore => 'Attempt graded.';

  @override
  String manualGradeErrorSnack(String message) {
    return 'Grade failed: $message';
  }

  @override
  String get teacherExamAddQuestionAction => 'Add question';

  @override
  String get teacherExamPublishAction => 'Publish exam';

  @override
  String get teacherExamPublishLoading => 'Publishing…';

  @override
  String get teacherExamPublishedSnack => 'Exam published.';

  @override
  String teacherExamPublishErrorSnack(String message) {
    return 'Publish failed: $message';
  }

  @override
  String get teacherExamQuestionPublishAction => 'Publish';

  @override
  String get teacherExamQuestionPublishLoading => 'Publishing…';

  @override
  String get teacherExamQuestionPublishedSnack => 'Question published.';

  @override
  String teacherExamQuestionPublishErrorSnack(String message) {
    return 'Publish failed: $message';
  }

  @override
  String get teacherExamQuestionFormTitle => 'Add question';

  @override
  String get teacherExamQuestionTypeHeader => 'Type';

  @override
  String get teacherExamQuestionTextHeader => 'Question text';

  @override
  String get teacherExamQuestionTextLabel => 'Question';

  @override
  String get teacherExamQuestionTextHint => 'What do you want to ask?';

  @override
  String get teacherExamQuestionTextRequired => 'Question text is required';

  @override
  String get teacherExamQuestionMarksHeader => 'Marks';

  @override
  String get teacherExamQuestionMarksLabel => 'Marks';

  @override
  String get teacherExamQuestionMarksHint => '1, 2, 5, …';

  @override
  String get teacherExamQuestionMarksRequired => 'Marks is required';

  @override
  String get teacherExamQuestionMarksInvalid => 'Enter a whole number';

  @override
  String get teacherExamQuestionMarksNegative => 'Marks must be greater than 0';

  @override
  String teacherExamQuestionOptionsHeader(int count) {
    return 'Options ($count)';
  }

  @override
  String get teacherExamQuestionAddOption => 'Add option';

  @override
  String get teacherExamQuestionSubmitAction => 'Save question';

  @override
  String get teacherExamQuestionSubmitLoading => 'Saving…';

  @override
  String get teacherExamQuestionCreatedSnack => 'Question added.';

  @override
  String teacherExamQuestionErrorSnack(String message) {
    return 'Save failed: $message';
  }

  @override
  String get staffListScreenTitle => 'Staff';

  @override
  String get staffListSearchHint => 'Search by name or role';

  @override
  String get staffListNewStaffAction => 'New staff';

  @override
  String get staffListLoadingTitle => 'Loading staff';

  @override
  String get staffListLoadingMessage =>
      'Fetching the latest roster from the server.';

  @override
  String get staffListEmptyTitle => 'No staff yet';

  @override
  String get staffListEmptyFilterTitle => 'No staff match the current filter';

  @override
  String get staffListEmptyMessage =>
      'Add the first staff member to get started.';

  @override
  String get staffListEmptyFilterMessage =>
      'Try clearing the search or the role filter.';

  @override
  String get staffListAddStaffAction => 'Add staff';

  @override
  String get staffListErrorTitle => 'Could not load staff';

  @override
  String get staffListFilterRole => 'Role';

  @override
  String get staffListFilterClear => 'Clear';

  @override
  String get staffListFilterRoleTitle => 'Filter by role';

  @override
  String get staffListFilterRoleTeacher => 'Teacher';

  @override
  String get staffListFilterRolePrincipal => 'Principal';

  @override
  String get staffListFilterRoleVicePrincipal => 'Vice Principal';

  @override
  String get staffListFilterRoleCounselor => 'Counselor';

  @override
  String get staffListFilterRoleLibrarian => 'Librarian';

  @override
  String get staffListFilterRoleAdmin => 'Admin';

  @override
  String get staffDetailScreenTitle => 'Staff';

  @override
  String get staffDetailLoadingTitle => 'Loading staff';

  @override
  String get staffDetailErrorTitle => 'Could not load staff';

  @override
  String get staffDetailRoleBranchHeader => 'Role & branch';

  @override
  String get staffDetailRoleLabel => 'Role';

  @override
  String get staffDetailBranchLabel => 'Branch';

  @override
  String get staffDetailStatusLabel => 'Status';

  @override
  String get staffDetailDateOfJoiningLabel => 'Date of joining';

  @override
  String get staffDetailUserAccountLabel => 'User account';

  @override
  String get staffDetailIdentityHeader => 'Identity & contact';

  @override
  String get staffDetailGenderLabel => 'Gender';

  @override
  String get staffDetailNationalityLabel => 'Nationality';

  @override
  String get staffDetailCountryLabel => 'Country';

  @override
  String get staffDetailErpnextEmployeeLabel => 'ERPNext employee';

  @override
  String get staffDetailNoDataLabel => 'No data on file.';

  @override
  String get staffStatusActive => 'Active';

  @override
  String get staffCreateScreenTitle => 'New staff';

  @override
  String get staffCreateLoadingTitle => 'Loading form';

  @override
  String get staffCreateLoadingMessage =>
      'Fetching the school staff setup context.';

  @override
  String get staffCreateErrorTitle => 'Could not load the form schema';

  @override
  String get staffCreateIdentityHeader => 'Identity';

  @override
  String get staffCreateFirstNameLabel => 'First name';

  @override
  String get staffCreateLastNameLabel => 'Last name';

  @override
  String get staffCreateRoleHeader => 'Role';

  @override
  String get staffCreateRoleLabel => 'Role';

  @override
  String get staffCreateRoleHint => 'Teacher';

  @override
  String get staffCreateContactHeader => 'Contact';

  @override
  String get staffCreateEmailLabel => 'Email';

  @override
  String get staffCreatePhoneLabel => 'Phone';

  @override
  String get staffCreateCountryHeader => 'Country & nationality';

  @override
  String get staffCreateNationalityLabel => 'Nationality';

  @override
  String get staffCreateCountryLabel => 'Country of residence';

  @override
  String get staffCreateDateHeader => 'Joining date';

  @override
  String get staffCreateDateOfJoiningLabel => 'Date of joining';

  @override
  String get staffCreateDateOfJoiningHint => 'YYYY-MM-DD';

  @override
  String get staffCreateNotesHeader => 'Notes';

  @override
  String get staffCreateNotesLabel => 'Notes';

  @override
  String get staffCreateSuccessTitle => 'Staff member created';

  @override
  String get staffCreateSuccessFallback => 'The staff record is on file.';

  @override
  String staffCreateEmployeeChip(String id) {
    return 'Employee: $id';
  }

  @override
  String get staffCreateAnotherAction => 'Create another';

  @override
  String get staffCreateOpenRecordAction => 'Open record';

  @override
  String get staffCreateSubmitAction => 'Create staff';

  @override
  String get staffCreateSubmitLoading => 'Creating…';

  @override
  String get guardianListScreenTitle => 'Guardians';

  @override
  String get guardianListSearchHint => 'Search by name, phone, or email';

  @override
  String get guardianListNewGuardianAction => 'New guardian';

  @override
  String get guardianListLoadingTitle => 'Loading guardians';

  @override
  String get guardianListLoadingMessage =>
      'Fetching the latest roster from the server.';

  @override
  String get guardianListEmptyTitle => 'No guardians yet';

  @override
  String get guardianListEmptyFilterTitle =>
      'No guardians match the current filter';

  @override
  String get guardianListEmptyMessage =>
      'Add the first guardian to get started.';

  @override
  String get guardianListEmptyFilterMessage =>
      'Try clearing the search or the relation filter.';

  @override
  String get guardianListAddGuardianAction => 'Add guardian';

  @override
  String get guardianListErrorTitle => 'Could not load guardians';

  @override
  String get guardianListFilterRelation => 'Relation';

  @override
  String get guardianListFilterClear => 'Clear';

  @override
  String get guardianListFilterRelationTitle => 'Filter by relation';

  @override
  String get guardianListFilterRelationFather => 'Father';

  @override
  String get guardianListFilterRelationMother => 'Mother';

  @override
  String get guardianListFilterRelationBrother => 'Brother';

  @override
  String get guardianListFilterRelationSister => 'Sister';

  @override
  String get guardianListFilterRelationUncle => 'Uncle';

  @override
  String get guardianListFilterRelationAunt => 'Aunt';

  @override
  String get guardianListFilterRelationGrandparent => 'Grandparent';

  @override
  String get guardianListFilterRelationOther => 'Other';

  @override
  String guardianListLinkedChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get guardianDetailScreenTitle => 'Guardian';

  @override
  String get guardianDetailLoadingTitle => 'Loading guardian';

  @override
  String get guardianDetailErrorTitle => 'Could not load guardian';

  @override
  String get guardianDetailLinkedHeader => 'Linked students';

  @override
  String get guardianDetailContactHeader => 'Contact';

  @override
  String get guardianDetailPhoneLabel => 'Phone';

  @override
  String get guardianDetailEmailLabel => 'Email';

  @override
  String get guardianDetailOccupationLabel => 'Occupation';

  @override
  String get guardianDetailAddressHeader => 'Address';

  @override
  String get guardianDetailAddressLine1Label => 'Address line 1';

  @override
  String get guardianDetailAddressLine2Label => 'Address line 2';

  @override
  String get guardianDetailCityLabel => 'City';

  @override
  String get guardianDetailPostalCodeLabel => 'Postal code';

  @override
  String get guardianDetailCountryLabel => 'Country';

  @override
  String get guardianDetailNationalityLabel => 'Nationality';

  @override
  String get guardianDetailNoDataLabel => 'No data on file.';

  @override
  String get guardianCreateScreenTitle => 'New guardian';

  @override
  String get guardianCreateLoadingTitle => 'Loading form';

  @override
  String get guardianCreateLoadingMessage =>
      'Fetching the school guardian setup context.';

  @override
  String get guardianCreateErrorTitle => 'Could not load the form schema';

  @override
  String get guardianCreateIdentityHeader => 'Identity';

  @override
  String get guardianCreateNameLabel => 'Guardian name';

  @override
  String get guardianCreateRelationHeader => 'Relation';

  @override
  String get guardianCreateRelationLabel => 'Relation';

  @override
  String get guardianCreateRelationHint => 'Father, Mother, …';

  @override
  String get guardianCreateContactHeader => 'Contact';

  @override
  String get guardianCreatePhoneLabel => 'Phone';

  @override
  String get guardianCreateEmailLabel => 'Email';

  @override
  String get guardianCreateOccupationLabel => 'Occupation';

  @override
  String get guardianCreateAddressHeader => 'Address';

  @override
  String get guardianCreateAddressLine1Label => 'Address line 1';

  @override
  String get guardianCreateAddressLine2Label => 'Address line 2';

  @override
  String get guardianCreateCityLabel => 'City';

  @override
  String get guardianCreatePostalCodeLabel => 'Postal code';

  @override
  String get guardianCreateNationalityLabel => 'Nationality';

  @override
  String get guardianCreateCountryLabel => 'Country';

  @override
  String get guardianCreateSuccessTitle => 'Guardian created';

  @override
  String get guardianCreateSuccessFallback => 'The guardian record is on file.';

  @override
  String get guardianCreateAnotherAction => 'Create another';

  @override
  String get guardianCreateOpenRecordAction => 'Open record';

  @override
  String get guardianCreateSubmitAction => 'Create guardian';

  @override
  String get guardianCreateSubmitLoading => 'Creating…';

  @override
  String get commonActive => 'Active';

  @override
  String get commonPrimary => 'Primary';

  @override
  String get academicsScreenTitle => 'Academics';

  @override
  String get academicsNewSubjectAction => 'New subject';

  @override
  String get academicsTabSubjects => 'Subjects';

  @override
  String get academicsTabTimetable => 'Timetable';

  @override
  String get academicsTabBranches => 'Branches';

  @override
  String get academicsSearchHint => 'Search by name, code, or department';

  @override
  String get academicsLoadingSubjects => 'Loading subjects';

  @override
  String get academicsErrorSubjects => 'Could not load subjects';

  @override
  String get academicsEmptySubjectsTitle => 'No subjects yet';

  @override
  String get academicsEmptySubjectsMessage =>
      'Add the first subject to get started.';

  @override
  String get academicsAddSubjectAction => 'Add subject';

  @override
  String get academicsLoadingTimetable => 'Loading timetable';

  @override
  String get academicsErrorTimetable => 'Could not load timetable';

  @override
  String get academicsEmptyTimetableTitle => 'No timetable slots';

  @override
  String get academicsEmptyTimetableMessage =>
      'The school has not published any timetable slots yet.';

  @override
  String get academicsLoadingBranches => 'Loading branches';

  @override
  String get academicsErrorBranches => 'Could not load branches';

  @override
  String get academicsEmptyBranchesTitle => 'No branches yet';

  @override
  String get academicsEmptyBranchesMessage =>
      'Add the first branch from the school admin console.';

  @override
  String get subjectCreateScreenTitle => 'New subject';

  @override
  String get subjectCreateSuccessTitle => 'Subject created';

  @override
  String get subjectCreateBackAction => 'Back to academics';

  @override
  String get subjectCreateNameLabel => 'Subject name';

  @override
  String get subjectCreateNameHint => 'Mathematics, Arabic, …';

  @override
  String get subjectCreateCodeLabel => 'Subject code';

  @override
  String get subjectCreateCodeHint => 'MATH-101';

  @override
  String get subjectCreateDepartmentLabel => 'Department';

  @override
  String get subjectCreateDepartmentHint => 'Sciences, Humanities, …';

  @override
  String get subjectCreateGradeLevelLabel => 'Grade level';

  @override
  String get subjectCreateGradeLevelHint => 'Grade 3';

  @override
  String get subjectCreateCreditHoursLabel => 'Credit hours';

  @override
  String get subjectCreateDescriptionLabel => 'Description';

  @override
  String get subjectCreateSubmitAction => 'Create subject';

  @override
  String get subjectCreateSubmitLoading => 'Creating…';

  @override
  String get attendanceListScreenTitle => 'Attendance';

  @override
  String get attendanceListCaptureAction => 'Capture';

  @override
  String get attendanceListLoadingTitle => 'Loading attendance';

  @override
  String get attendanceListLoadingMessage =>
      'Fetching the latest records from the server.';

  @override
  String get attendanceListEmptyTitle => 'No attendance records yet';

  @override
  String get attendanceListEmptyMessage =>
      'Tap Capture to start the daily attendance for a class group.';

  @override
  String get attendanceListStartCaptureAction => 'Start capture';

  @override
  String get attendanceListErrorTitle => 'Could not load attendance';

  @override
  String get attendanceListPickClassGroup => 'Pick a class group';

  @override
  String attendanceListClassGroupLabel(String name) {
    return 'Class group $name';
  }

  @override
  String get attendanceStatusPresent => 'P';

  @override
  String get attendanceStatusAbsent => 'A';

  @override
  String get attendanceStatusLate => 'L';

  @override
  String get attendanceStatusExcused => 'E';

  @override
  String get attendanceStatusPresentLong => 'Present';

  @override
  String get attendanceStatusAbsentLong => 'Absent';

  @override
  String get attendanceStatusLateLong => 'Late';

  @override
  String get attendanceStatusExcusedLong => 'Excused';

  @override
  String attendanceCaptureTitle(String classGroup) {
    return 'Attendance · $classGroup';
  }

  @override
  String get attendanceCaptureRosterErrorTitle => 'Could not load the roster';

  @override
  String get attendanceCaptureRosterLoadingTitle => 'Loading roster';

  @override
  String get attendanceCaptureRosterLoadingMessage =>
      'Fetching the class group from the server.';

  @override
  String get attendanceCaptureEmptyTitle => 'No students in this class group';

  @override
  String get attendanceCaptureEmptyMessage =>
      'Once students are enrolled, attendance capture is enabled.';

  @override
  String attendanceCaptureCountPresent(int count) {
    return 'P $count';
  }

  @override
  String attendanceCaptureCountAbsent(int count) {
    return 'A $count';
  }

  @override
  String attendanceCaptureCountLate(int count) {
    return 'L $count';
  }

  @override
  String attendanceCaptureCountExcused(int count) {
    return 'E $count';
  }

  @override
  String get attendanceCaptureMarkAllPresent => 'Mark all present';

  @override
  String get attendanceCaptureMarkAllAbsent => 'Mark all absent';

  @override
  String attendanceCaptureSuccessAll(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return 'Submitted $_temp0 for $date.';
  }

  @override
  String attendanceCaptureSuccessPartial(int succeeded, int failed, int total) {
    return 'Submitted $succeeded, failed $failed of $total.';
  }

  @override
  String get attendanceCaptureSubmit => 'Submit attendance';

  @override
  String get attendanceCaptureResubmit => 'Re-submit';

  @override
  String get attendanceCaptureSubmitLoading => 'Submitting…';

  @override
  String attendanceGuardianLabel(String name) {
    return 'Guardian: $name';
  }

  @override
  String get examsListScreenTitle => 'Exams';

  @override
  String get examsListLoadingTitle => 'Loading exams';

  @override
  String get examsListLoadingMessage => 'Fetching the published exam plans.';

  @override
  String get examsListEmptyTitle => 'No published exams';

  @override
  String get examsListEmptyMessage =>
      'When a teacher publishes an exam, it shows up here.';

  @override
  String get examsListErrorTitle => 'Could not load exams';

  @override
  String get examsListStatusOpen => 'Open';

  @override
  String get examsListStatusDraft => 'Draft';

  @override
  String examsListDurationMinutesChip(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get examAttemptScreenTitle => 'Exam attempt';

  @override
  String get examAttemptAutosaveArmed => 'Autosave armed';

  @override
  String examAttemptAutosaveSaved(String time) {
    return 'Saved at $time';
  }

  @override
  String get examAttemptAutosaveFailed => 'Autosave failed';

  @override
  String get examAttemptEligibilityLoadingTitle => 'Checking eligibility';

  @override
  String get examAttemptEligibilityErrorTitle => 'Could not check eligibility';

  @override
  String get examAttemptIneligibleTitle => 'Not eligible';

  @override
  String get examAttemptIneligibleMessage =>
      'The server says you cannot take this exam.';

  @override
  String get examAttemptBackToExams => 'Back to exams';

  @override
  String get examAttemptAbandonedTitle => 'Attempt abandoned';

  @override
  String get examAttemptAbandonedMessage =>
      'You abandoned this attempt. The server marked it as abandoned.';

  @override
  String get examAttemptSubmittedTitle => 'Submitted';

  @override
  String get examAttemptSubmittedMessage =>
      'Your answers are on the server. Check back when the result is published.';

  @override
  String get examAttemptStartErrorTitle => 'Could not start the attempt';

  @override
  String get examAttemptNoStudentError =>
      'No student resolved. Sign in and retry.';

  @override
  String get examAttemptReadyTitle => 'Ready to start?';

  @override
  String get examAttemptResolvingStudent => 'Resolving student…';

  @override
  String examAttemptResolveStudentError(String error) {
    return 'Could not resolve student: $error';
  }

  @override
  String examAttemptStudentLabel(String name) {
    return 'Student: $name';
  }

  @override
  String get examAttemptAutosaveChip => 'Autosave every 15s';

  @override
  String get examAttemptResolvingLabel => 'Resolving…';

  @override
  String get examAttemptStartAction => 'Start attempt';

  @override
  String get examAttemptNoQuestionsTitle => 'No questions';

  @override
  String get examAttemptNoQuestionsMessage =>
      'The server did not return any questions for this attempt.';

  @override
  String get examAttemptAbandon => 'Abandon';

  @override
  String get examAttemptAbandoning => 'Abandoning…';

  @override
  String get examAttemptSubmit => 'Submit attempt';

  @override
  String get examAttemptSubmitting => 'Submitting…';

  @override
  String get examAttemptAbandonDialogTitle => 'Abandon attempt?';

  @override
  String get examAttemptAbandonDialogMessage =>
      'This will mark the attempt as abandoned on the server. You cannot resume it.';

  @override
  String examAttemptMarksChip(int marks) {
    String _temp0 = intl.Intl.pluralLogic(
      marks,
      locale: localeName,
      other: '$marks pts',
      one: '1 pt',
    );
    return '$_temp0';
  }

  @override
  String get examAttemptAnswerHint => 'Type your answer…';

  @override
  String get gradingCorrectionScreenTitle => 'Correct grade';

  @override
  String get gradingCorrectionLoadingTitle => 'Loading form';

  @override
  String get gradingCorrectionLoadingMessage =>
      'Fetching the grade record setup context.';

  @override
  String get gradingCorrectionErrorTitle => 'Could not load the form';

  @override
  String get gradingCorrectionTargetHeader => 'Target grade';

  @override
  String get gradingCorrectionGradeLabel => 'Grade ID';

  @override
  String get gradingCorrectionScoresHeader => 'Scores';

  @override
  String get gradingCorrectionScoreLabel => 'Score';

  @override
  String get gradingCorrectionScoreHint => '0';

  @override
  String get gradingCorrectionMaxScoreLabel => 'Max score';

  @override
  String get gradingCorrectionMaxScoreHint => '100';

  @override
  String get gradingCorrectionReasonHeader => 'Reason';

  @override
  String get gradingCorrectionReasonLabel => 'Reason';

  @override
  String get gradingCorrectionReasonHint => 'Why is this correction needed?';

  @override
  String get gradingCorrectionSubmitAction => 'Apply correction';

  @override
  String get gradingCorrectionSubmitLoading => 'Applying…';

  @override
  String get gradingCorrectionSuccessTitle => 'Grade corrected';

  @override
  String get gradingCorrectionSuccessFallback => 'The grade record is on file.';

  @override
  String gradingCorrectionSuccessLabel(String name) {
    return 'Grade $name corrected';
  }

  @override
  String gradingCorrectionScoreChip(double score) {
    return 'Score: $score';
  }

  @override
  String gradingCorrectionMaxScoreChip(double max) {
    return 'Max: $max';
  }

  @override
  String gradingCorrectionActorChip(String actor) {
    return 'By $actor';
  }

  @override
  String gradingCorrectionTimestampLabel(String timestamp) {
    return 'Corrected at $timestamp';
  }

  @override
  String get gradingCorrectionAnotherAction => 'Correct another';

  @override
  String get gradingCorrectionBackAction => 'Back to grading';

  @override
  String get gradingCorrectionAction => 'Correct a grade';

  @override
  String get gradingCorrectionPromptTitle => 'Correct a grade';

  @override
  String get gradingCorrectionPromptHint =>
      'Enter the grade ID (e.g. GR-00001)';

  @override
  String get gradingApprovePolicyAction => 'Approve policy';

  @override
  String gradingApprovePolicySuccess(String name) {
    return 'Approved $name.';
  }

  @override
  String gradingApprovePolicyError(String message) {
    return 'Could not approve policy: $message';
  }

  @override
  String get gradingPromoteAction => 'Promote assessment result';

  @override
  String get gradingPromotePromptTitle => 'Promote assessment result';

  @override
  String get gradingPromoteResultLabel => 'Assessment result ID';

  @override
  String get gradingPromoteResultHint => 'e.g. AR-00001';

  @override
  String get gradingPromotePolicyLabel => 'Policy name';

  @override
  String get gradingPromotePolicyHint => 'e.g. SGP-MATH-G7';

  @override
  String gradingPromoteSuccess(String id) {
    return 'Promoted to grade record $id.';
  }

  @override
  String get gradingPromoteSuccessFallback => 'Assessment result promoted.';

  @override
  String gradingPromoteError(String message) {
    return 'Could not promote: $message';
  }

  @override
  String get operationsReplayAction => 'Replay';

  @override
  String get operationsReceiveCallbackAction => 'Receive callback';

  @override
  String get operationsReplayPromptTitle => 'Replay a delivery event';

  @override
  String get operationsReplayEventKeyLabel => 'Event key';

  @override
  String get operationsReplayEventKeyHint =>
      'e.g. comm-delivery-2026-08-01-abc';

  @override
  String get operationsReplayReasonLabel => 'Reason (optional)';

  @override
  String get operationsReplayReasonHint => 'Why is the replay needed?';

  @override
  String operationsReplaySuccessSnack(String key) {
    return 'Replayed event $key.';
  }

  @override
  String operationsReplayStatusSnack(String status) {
    return 'Replay status: $status.';
  }

  @override
  String operationsReplayErrorSnack(String message) {
    return 'Replay failed: $message';
  }

  @override
  String get operationsReceiveCallbackPromptTitle =>
      'Receive a delivery callback';

  @override
  String get operationsReceiveCallbackProviderLabel => 'Provider';

  @override
  String get operationsReceiveCallbackProviderHint =>
      'e.g. stripe / sendgrid / fcm';

  @override
  String get operationsReceiveCallbackSignatureLabel => 'Signature (optional)';

  @override
  String get operationsReceiveCallbackSignatureHint =>
      'X-Signature header value';

  @override
  String get operationsReceiveCallbackBodyLabel => 'Body (optional)';

  @override
  String get operationsReceiveCallbackBodyHint =>
      'Raw callback body (JSON / form)';

  @override
  String operationsReceiveCallbackSuccessSnack(String key) {
    return 'Callback received for $key.';
  }

  @override
  String operationsReceiveCallbackStatusSnack(String status) {
    return 'Callback status: $status.';
  }

  @override
  String operationsReceiveCallbackErrorSnack(String message) {
    return 'Callback failed: $message';
  }

  @override
  String get privacyRequestSubmitScreenTitle => 'Submit a privacy request';

  @override
  String get privacyRequestSubmitTypeHeader => 'Request type';

  @override
  String get privacyRequestTypeAccess => 'Data access';

  @override
  String get privacyRequestTypeRectification => 'Rectification';

  @override
  String get privacyRequestTypeErasure => 'Erasure';

  @override
  String get privacyRequestTypeConsentWithdrawal => 'Consent withdrawal';

  @override
  String get privacyRequestTypeLegalHold => 'Legal hold';

  @override
  String get privacyRequestSubmitCategoriesHeader => 'Data categories';

  @override
  String get privacyRequestSubmitAuthorityHeader => 'Authority';

  @override
  String get privacyRequestSubmitAuthorityLabel => 'Authority reference';

  @override
  String get privacyRequestSubmitAuthorityHint =>
      'e.g. ticket id or email thread id';

  @override
  String get privacyRequestSubmitAuthorityRequired =>
      'An authority reference is required.';

  @override
  String get privacyRequestSubmitBranchHeader => 'School branch';

  @override
  String get privacyRequestSubmitBranchLabel => 'School branch';

  @override
  String get privacyRequestSubmitBranchHint => 'e.g. main / north / campus-2';

  @override
  String get privacyRequestSubmitBranchRequired =>
      'A school branch is required.';

  @override
  String get privacyRequestSubmitNoteHeader => 'Note (optional)';

  @override
  String get privacyRequestSubmitNoteLabel => 'Note';

  @override
  String get privacyRequestSubmitNoteHint => 'Why is this request needed?';

  @override
  String get privacyRequestSubmitAction => 'Submit request';

  @override
  String get privacyRequestSubmitLoading => 'Submitting…';

  @override
  String get privacyRequestSubmitSummaryHeader => 'Request context';

  @override
  String get privacyRequestSubmitSummaryRequester => 'Requester type';

  @override
  String get privacyRequestSubmitSummarySubject => 'Subject';

  @override
  String get privacyRequestSubmitSummaryBranch => 'School branch';

  @override
  String get privacyRequestSubmitSuccessTitle => 'Privacy request submitted';

  @override
  String get privacyRequestSubmitSuccessFallback => 'The request is on file.';

  @override
  String privacyRequestSubmitSuccessLabel(String id) {
    return 'Request $id submitted.';
  }

  @override
  String get privacyRequestSubmitBackAction => 'Back to my family';

  @override
  String get privacyRequestCategoryPersonal => 'Personal';

  @override
  String get privacyRequestCategoryAttendance => 'Attendance';

  @override
  String get privacyRequestCategoryGrades => 'Grades';

  @override
  String get privacyRequestCategoryFees => 'Fees';

  @override
  String get privacyRequestCategoryHealth => 'Health';

  @override
  String get privacyRequestCategoryCommunications => 'Communications';

  @override
  String get governanceApproveSettingsAction => 'Approve settings';

  @override
  String get governanceApproveSettingsPromptTitle =>
      'Approve governance settings';

  @override
  String get governanceApproveSettingsVersionLabel => 'Policy version';

  @override
  String get governanceApproveSettingsVersionHint => 'e.g. 3';

  @override
  String get governanceApproveSettingsReasonLabel => 'Reason (optional)';

  @override
  String get governanceApproveSettingsReasonHint =>
      'Why is the approval needed?';

  @override
  String governanceApproveSettingsSuccess(int version) {
    return 'Approved policy version $version.';
  }

  @override
  String get governanceApproveSettingsSuccessFallback => 'Settings approved.';

  @override
  String governanceApproveSettingsError(String message) {
    return 'Could not approve settings: $message';
  }
}
