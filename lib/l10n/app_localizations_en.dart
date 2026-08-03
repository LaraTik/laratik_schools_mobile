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
}
