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
  String get homeTeacherMySchool => 'My school';

  @override
  String get homeTeacherMyClasses => 'My classes';

  @override
  String get homeTeacherCaptureAttendance => 'Capture attendance';

  @override
  String get homeTeacherCaptureAttendanceSubtitle => 'Mark a class group';

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
  String get homeAdminFeePlans => 'Fee plans';

  @override
  String get homeAdminFeePlansSubtitle => 'Review issued + outstanding plans';

  @override
  String get homeAdminFeeOperations => 'Fee operations';

  @override
  String get homeAdminFeeOperationsSubtitle =>
      'Invoiced / collected / outstanding';

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
}
