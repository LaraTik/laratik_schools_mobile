// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لاراتيك سكولز';

  @override
  String get navStudents => 'الطلاب';

  @override
  String get navStaff => 'الموظفون';

  @override
  String get navGuardians => 'أولياء الأمور';

  @override
  String get navAcademics => 'الأكاديمي';

  @override
  String get navAttendance => 'الحضور';

  @override
  String get navMyClasses => 'صفوفي';

  @override
  String get navFees => 'الرسوم';

  @override
  String get shellDashboard => 'الرئيسية';

  @override
  String get shellNotifications => 'الإشعارات';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonTryAgain => 'إعادة المحاولة';

  @override
  String get commonClearSearch => 'مسح البحث';

  @override
  String get commonNoResults => 'لا توجد نتائج';

  @override
  String get commonLoading => 'جارٍ التحميل';

  @override
  String get commonError => 'حدث خطأ ما';

  @override
  String get homeParentMyChildren => 'أطفالي';

  @override
  String get homeParentNoChildrenTitle => 'لا يوجد أطفال مرتبطون بعد';

  @override
  String get homeParentNoChildrenMessage =>
      'عندما تربطك المدرسة بصفة ولي أمر، ستظهر أسماء أطفالك هنا. إذا كنت تتوقع رؤية طفل ولا يظهر، فاتصل بمكتب المدرسة للتأكد من إتمام الربط.';

  @override
  String get homeParentInbox => 'صندوق الوارد';

  @override
  String get homeParentInboxEmpty => 'لا توجد رسائل جديدة';

  @override
  String homeParentInboxUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة غير مقروءة',
      many: '$count رسالة غير مقروءة',
      few: '$count رسائل غير مقروءة',
      two: 'رسالتان غير مقروءتان',
      one: 'رسالة واحدة غير مقروءة',
      zero: 'لا توجد رسائل جديدة',
    );
    return '$_temp0';
  }

  @override
  String get homeStudentMySchool => 'مدرستي';

  @override
  String get homeStudentResolving => 'جارٍ تحديد الطالب…';

  @override
  String get homeStudentResolvingMessage => 'نبحث عن الطالب النشط لهذا الجهاز.';

  @override
  String get homeStudentResolvingFailed => 'فشل تحديد الطالب';

  @override
  String get homeStudentNoStudent => 'لم يتم تحديد طالب';

  @override
  String get homeStudentNoStudentMessage =>
      'لا يوجد طلاب مسجلون في هذا الموقع بعد.';

  @override
  String get homeStudentSwitchStudent => 'تبديل الطالب';

  @override
  String get homeStudentToday => 'اليوم';

  @override
  String get homeStudentMore => 'المزيد';

  @override
  String get homeStudentAllExams => 'جميع الاختبارات';

  @override
  String get homeStudentAllExamsSubtitle => 'تصفح كل اختبار منشور';

  @override
  String get homeStudentMyRecords => 'سجلاتي';

  @override
  String get homeStudentMyRecordsSubtitle => 'الدرجات والحضور وكشوف العلامات';

  @override
  String get homeTeacherMySchool => 'مدرستي';

  @override
  String get homeTeacherMyClasses => 'صفوفي';

  @override
  String get homeTeacherCaptureAttendance => 'تسجيل الحضور';

  @override
  String get homeTeacherCaptureAttendanceSubtitle => 'سجل لمجموعة صفية';

  @override
  String get homeAdminQuickStart => 'بدء سريع';

  @override
  String get homeAdminPracticeQuiz => 'اختبار تدريبي';

  @override
  String get homeAdminPracticeQuizSubtitle => 'اعقد اختبارًا منشورًا';

  @override
  String get homeAdminNewStudent => 'طالب جديد';

  @override
  String get homeAdminNewStudentSubtitle => 'سجّل من قسم القبول';

  @override
  String get homeAdminNewStaff => 'موظف جديد';

  @override
  String get homeAdminNewStaffSubtitle => 'أضف معلمًا أو مديرًا';

  @override
  String get homeAdminNewSubject => 'مادة جديدة';

  @override
  String get homeAdminNewSubjectSubtitle => 'أضف مادة إلى الكتالوج';

  @override
  String get homeAdminFeePlans => 'خطط الرسوم';

  @override
  String get homeAdminFeePlansSubtitle => 'راجع الخطط الصادرة والمعلقة';

  @override
  String get homeAdminFeeOperations => 'عمليات الرسوم';

  @override
  String get homeAdminFeeOperationsSubtitle => 'مُصدرة / محصلة / مستحقة';

  @override
  String myChildrenHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طفل مرتبط',
      many: '$count طفلاً مرتبطاً',
      few: '$count أطفال مرتبطون',
      two: 'طفلان مرتبطان',
      one: 'طفل واحد مرتبط',
      zero: 'لا يوجد أطفال مرتبطون',
    );
    return '$_temp0';
  }

  @override
  String myChildrenHeaderActive(int active, int inactive) {
    return '$active نشط · $inactive منسحب. تُحفظ روابط الانسحاب للرجوع إليها.';
  }

  @override
  String get myChildrenHeaderAllActive =>
      'انقر على طفل لرؤية درجاته وحضوره وكشوف علاماته.';

  @override
  String get myChildrenChildCurrent => 'الحالي';

  @override
  String get myChildrenChildActive => 'نشط';

  @override
  String get meSwitchStudentTitle => 'تبديل الطالب';

  @override
  String get meSwitchStudentSearch => 'ابحث بالاسم أو رقم الطالب';

  @override
  String meSwitchStudentNoResultsTitle(String query) {
    return 'لا يوجد طلاب يطابقون \"$query\"';
  }

  @override
  String get meSwitchStudentEmptyTitle => 'لا يوجد طلاب بعد';

  @override
  String get meSwitchStudentEmptyMessage =>
      'أضف طالبًا إلى القائمة، ثم عُد إلى هنا لاختيار واحد.';

  @override
  String get meSwitchStudentSearchingTitle => 'جارٍ البحث عن الطلاب';

  @override
  String get meSwitchStudentSearchingMessage => 'نبحث في القائمة.';

  @override
  String meSwitchStudentNowActingAs(String name) {
    return 'تتصرف الآن باسم $name';
  }

  @override
  String myClassesHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تعيين نشط',
      many: '$count تعييناً نشطاً',
      few: '$count تعيينات نشطة',
      two: 'تعيينان نشطان',
      one: 'تعيين نشط واحد',
      zero: 'لا توجد تعيينات نشطة',
    );
    return '$_temp0';
  }

  @override
  String myClassesHeaderActive(int active, int inactive) {
    return '$active نشط · $inactive غير نشط. تُحفظ التعيينات غير النشطة للرجوع إليها.';
  }

  @override
  String get myClassesHeaderAllActive =>
      'انقر على صف لرؤية قائمتك + اختباراتك في تلك المادة.';

  @override
  String get myClassesEmptyTitle => 'لا توجد صفوف معينة';

  @override
  String get myClassesEmptyMessage =>
      'ليس لديك أي تعيينات تدريس نشطة بعد. عندما يعينك قسم القبول على (صف، مادة)، سيظهر الصف هنا.';

  @override
  String get myClassesLoadingTitle => 'جارٍ تحميل صفوفك';

  @override
  String get myClassesLoadingMessage =>
      'نبحث عن أزواج (الصف، المادة) التي تدرّسها.';

  @override
  String get myClassesChipHomeroom => 'الفصل الرئيسي';

  @override
  String get classDetailRosterTitle => 'جارٍ تحميل القائمة';

  @override
  String get classDetailRosterMessage =>
      'نبحث عن الطلاب المعينين لهذه المجموعة الصفية.';

  @override
  String get classDetailRosterEmptyTitle => 'لا يوجد طلاب في هذا الصف بعد';

  @override
  String get classDetailRosterEmptyMessage =>
      'لا يوجد طلاب معينون لهذه المجموعة الصفية بعد. عندما يسجل قسم القبول الطلاب، سيظهرون هنا تلقائيًا.';

  @override
  String get classDetailHeaderClassGroup => 'المجموعة الصفية';

  @override
  String get childDetailTitleOwn => 'سجلاتي';

  @override
  String get childDetailTitleOther => 'الطفل';

  @override
  String get childDetailTabOverview => 'نظرة عامة';

  @override
  String get childDetailTabGrades => 'الدرجات';

  @override
  String get childDetailTabAttendance => 'الحضور';

  @override
  String get childDetailTabReports => 'كشوف العلامات';

  @override
  String get childDetailOverviewKpiGrades => 'الدرجات';

  @override
  String get childDetailOverviewKpiAverage => 'المعدل';

  @override
  String get childDetailOverviewKpiAttendance => 'الحضور';

  @override
  String get childDetailOverviewKpiReports => 'كشوف العلامات';

  @override
  String get childDetailOverviewMessageOwn =>
      'ملخص سريع لدرجاتك وحضورك وكشوف علامتك. افتح علامة تبويب أعلاه للحصول على القائمة الكاملة.';

  @override
  String get childDetailOverviewMessageOther =>
      'ملخص سريع لدرجات هذا الطفل وحضوره وكشوف علاماته. افتح علامة تبويب أعلاه للحصول على القائمة الكاملة.';

  @override
  String get childDetailOverviewTitleOwn => 'سجلاتك بنظرة واحدة';

  @override
  String get childDetailOverviewTitleOther => 'بنظرة واحدة';

  @override
  String get childDetailGradesEmptyTitle => 'لا توجد درجات بعد';

  @override
  String get childDetailGradesEmptyMessage =>
      'لا توجد درجات منشورة لهذا الطالب بعد. تظهر الدرجات الجديدة هنا بمجرد أن ينشرها المعلمون.';

  @override
  String get childDetailAttendanceEmptyTitle => 'لا يوجد حضور مسجل';

  @override
  String get childDetailAttendanceEmptyMessage =>
      'لم يُسجل حضور لهذا الطالب بعد. يظهر الحضور اليومي هنا بمجرد التقاطه.';

  @override
  String get childDetailReportsEmptyTitle => 'لا توجد كشوف علامات بعد';

  @override
  String get childDetailReportsEmptyMessage =>
      'لم تُنشر كشوف علامات لهذا الطالب بعد. تظهر ملخصات الفصول هنا بمجرد أن تنشرها المدرسة.';

  @override
  String get childDetailEmptyStateFallback => 'تعذّر تحميل السجلات';

  @override
  String get childDetailNoStudentTitle => 'لم يتم تحديد طالب لهذا الجهاز';

  @override
  String get childDetailNoStudentMessage =>
      'تعذر علينا تحديد الطالب الذي يتصرف باسمه هذا الجهاز. سجّل الخروج وأعد الدخول، أو اتصل بمكتب المدرسة إذا استمرت المشكلة.';

  @override
  String feePlansHeaderTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطة رسوم',
      many: '$count خطة رسوم',
      few: '$count خطط رسوم',
      two: 'خطتا رسوم',
      one: 'خطة رسوم واحدة',
      zero: 'لا توجد خطط رسوم',
    );
    return '$_temp0';
  }

  @override
  String get feePlansEmptyTitle => 'لا توجد خطط رسوم بعد';

  @override
  String get feePlansEmptyMessage =>
      'ليس لديك أي خطط رسوم نشطة بعد. عندما تُصدر المدرسة خطة لطفلك، ستظهر هنا مع تفصيل البنود وحالة الدفع.';

  @override
  String get feePlansLoadingTitle => 'جارٍ تحميل خطط الرسوم';

  @override
  String get feePlansLoadingMessage => 'نبحث عن أحدث خطط الرسوم من الخادم.';

  @override
  String get feePlansBreakdown => 'التفصيل';

  @override
  String get a11yRefreshTooltip => 'تحديث';

  @override
  String get a11yNotificationsTooltip => 'الإشعارات';

  @override
  String get a11ySwitchStudentTooltip => 'تبديل الطالب';

  @override
  String a11yActingAs(String name) {
    return 'تتصرف باسم $name';
  }

  @override
  String a11yUnreadNotifications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسائل غير مقروءة',
      one: 'رسالة واحدة غير مقروءة',
      zero: 'لا توجد رسائل غير مقروءة',
    );
    return '$_temp0';
  }
}
