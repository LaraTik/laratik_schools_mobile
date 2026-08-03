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
  String get homeStudentFeeInvoicesTitle => 'فواتيري';

  @override
  String get homeStudentFeeInvoicesSubtitle => 'المستحقة + المتأخرة';

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
  String homeStudentGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String homeStudentStudentId(String id) {
    return 'رقم الطالب: $id';
  }

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
  String get homeStudentNoExamsTitle => 'لا توجد اختبارات اليوم';

  @override
  String get homeStudentNoExamsMessage =>
      'لا توجد خطط اختبارات منشورة في انتظارك. ستظهر الاختبارات الجديدة هنا بمجرد أن ينشرها المعلمون.';

  @override
  String get homeStudentLoadingExamsTitle => 'جارٍ تحميل الاختبارات';

  @override
  String get homeStudentLoadingExamsMessage =>
      'نجلب كتالوج الاختبارات المنشورة.';

  @override
  String get homeStudentCouldNotLoadExams => 'تعذّر تحميل الاختبارات';

  @override
  String get homeStudentTakeNextExam => 'اعقد امتحانك التالي';

  @override
  String get homeStudentOpenExam => 'افتح الاختبار';

  @override
  String get homeStudentInboxSubtitle => 'صندوق الوارد + الإعلانات';

  @override
  String get homeParentMyFamily => 'عائلتي';

  @override
  String get homeParentFeeInvoicesTitle => 'فواتير الرسوم';

  @override
  String get homeParentFeeInvoicesSubtitle =>
      'راجع خطط الرسوم لطفلك وحالة الدفع.';

  @override
  String get homeParentHeroLoadingMessage => 'نبحث عن الطلاب المرتبطين بك.';

  @override
  String get homeParentHeroLoadingChip => 'جارٍ التحميل…';

  @override
  String get homeParentHeroErrorMessage =>
      'تعذّر تحميل أطفالك الآن. انقر لإعادة المحاولة.';

  @override
  String get homeParentHeroErrorChip => 'إعادة المحاولة';

  @override
  String homeParentLinkedChildren(int count) {
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
  String homeParentLinkedChildrenActive(int count, int active) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count طفل مرتبط · $active نشط. انقر لرؤية الدرجات والحضور وكشوف العلامات.',
      many:
          '$count طفلاً مرتبطاً · $active نشط. انقر لرؤية الدرجات والحضور وكشوف العلامات.',
      few:
          '$count أطفال مرتبطون · $active نشط. انقر لرؤية الدرجات والحضور وكشوف العلامات.',
      two:
          'طفلان مرتبطان · $active نشط. انقر لرؤية الدرجات والحضور وكشوف العلامات.',
      one: 'طفل واحد مرتبط · انقر لرؤية الدرجات والحضور وكشوف العلامات.',
    );
    return '$_temp0';
  }

  @override
  String get homeTeacherMySchool => 'مدرستي';

  @override
  String get homeTeacherMyClasses => 'صفوفي';

  @override
  String get homeTeacherCaptureAttendance => 'تسجيل الحضور';

  @override
  String get homeTeacherCaptureAttendanceSubtitle => 'سجل لمجموعة صفية';

  @override
  String get homeTeacherInboxSubtitle => 'صندوق الوارد + الإعلانات';

  @override
  String get homeTeacherQuickStart => 'بدء سريع';

  @override
  String get homeTeacherHeroLoadingMessage =>
      'نبحث عن أزواج (الصف، المادة) التي تدرّسها.';

  @override
  String get homeTeacherHeroLoadingChip => 'جارٍ التحميل…';

  @override
  String get homeTeacherHeroErrorMessage =>
      'تعذّر تحميل صفوفك الآن. انقر لإعادة المحاولة.';

  @override
  String get homeTeacherHeroErrorChip => 'إعادة المحاولة';

  @override
  String homeTeacherHeroActive(int count, int active) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count تعيين · $active نشط. انقر لرؤية قائمتك + اختباراتك في تلك المادة.',
      many:
          '$count تعييناً · $active نشط. انقر لرؤية قائمتك + اختباراتك في تلك المادة.',
      few:
          '$count تعيينات · $active نشط. انقر لرؤية قائمتك + اختباراتك في تلك المادة.',
      two:
          'تعيينان · $active نشط. انقر لرؤية قائمتك + اختباراتك في تلك المادة.',
      one: 'تعيين تدريس واحد · انقر لرؤية قائمتك + اختباراتك في تلك المادة.',
    );
    return '$_temp0';
  }

  @override
  String get homeTeacherHeroEmpty =>
      'عندما يعينك قسم القبول على (صف، مادة)، سيظهر الصف هنا.';

  @override
  String get homeAdminMyHome => 'الرئيسية';

  @override
  String homeAdminActingAs(String name) {
    return 'تتصرف باسم: $name';
  }

  @override
  String homeAdminSignedInAs(String role) {
    return 'مسجّل الدخول باسم: $role';
  }

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
  String get homeAdminCaptureAttendance => 'تسجيل الحضور';

  @override
  String get homeAdminCaptureAttendanceSubtitle => 'سجل لمجموعة صفية';

  @override
  String get homeAdminFeePlans => 'خطط الرسوم';

  @override
  String get homeAdminFeePlansSubtitle => 'راجع الخطط الصادرة والمعلقة';

  @override
  String get homeAdminFeeOperations => 'عمليات الرسوم';

  @override
  String get homeAdminFeeOperationsSubtitle => 'مُصدرة / محصلة / مستحقة';

  @override
  String get homeAdminOperations => 'العمليات';

  @override
  String get homeAdminOperationsSubtitle => 'صحة النظام، التسليم، سجل التدقيق';

  @override
  String get homeAdminGovernance => 'الحوكمة';

  @override
  String get homeAdminGovernanceSubtitle =>
      'طلبات الخصوصية، الحجز القانوني، الاحتفاظ';

  @override
  String get homeAdminGrading => 'الدرجات';

  @override
  String get homeAdminGradingSubtitle => 'نظرة عامة، السياسات، مراجعة كل سجل';

  @override
  String get homeAdminNotificationsSubtitle => 'صندوق الوارد + الإعلانات';

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

  @override
  String get familyHomeLoadingTitle => 'جارٍ تحميل أطفالك';

  @override
  String get familyHomeErrorTitle => 'تعذّر تحميل أطفالك';

  @override
  String familyChildRowRelation(String relation) {
    return 'بصفة $relation';
  }

  @override
  String familyChildRowId(String code) {
    return 'الرقم $code';
  }

  @override
  String get childDetailLoadingTitle => 'جارٍ تحميل السجلات';

  @override
  String get childDetailLoadingMessage =>
      'نجلب الدرجات والحضور وكشوف العلامات.';

  @override
  String get childDetailGradeAssessmentFallback => 'التقييم';

  @override
  String get childDetailGradePass => 'ناجح';

  @override
  String get childDetailGradeFail => 'راسب';

  @override
  String childDetailGradePublishedOn(String date) {
    return 'نُشر في $date';
  }

  @override
  String get childDetailReportCardFallback => 'كشف العلامات';

  @override
  String get childDetailAverageOnTrack => 'ضمن المعدل';

  @override
  String get childDetailAverageBelowTarget => 'أقل من الهدف';

  @override
  String get childDetailAverageNoGrades => 'لا توجد درجات بعد';

  @override
  String get childDetailGradesAllPassed => 'نجح الجميع';

  @override
  String childDetailGradesOfTotalPassed(int passed, int total) {
    return '$passed من $total ناجح';
  }

  @override
  String get childDetailAttendanceNoAbsences => 'لا توجد غيابات';

  @override
  String childDetailAttendanceKpiSub(int present, int absent) {
    return '$present حاضر · $absent غائب';
  }

  @override
  String childDetailAttendanceKpiSubLate(int present, int absent, int late) {
    return '$present حاضر · $absent غائب · $late متأخر';
  }

  @override
  String get childDetailReportCardNoCards => 'لا توجد كشوف بعد';

  @override
  String childDetailReportCardLatest(String label) {
    return 'الأخير: $label';
  }

  @override
  String get meSwitchStudentErrorTitle => 'تعذّر تحميل الطلاب';

  @override
  String get meSwitchStudentNoResultsMessage =>
      'جرّب بحثًا أقصر، أو امسح البحث لرؤية القائمة الكاملة.';

  @override
  String get myClassesErrorTitle => 'تعذّر تحميل صفوفك';

  @override
  String myClassesAcademicYear(String year) {
    return 'العام الدراسي $year';
  }

  @override
  String get classDetailTitle => 'الصف';

  @override
  String get classDetailErrorTitle => 'تعذّر تحميل القائمة';

  @override
  String classDetailStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طالب',
      many: '$count طالباً',
      few: '$count طلاب',
      two: 'طالبان',
      one: 'طالب واحد',
    );
    return '$_temp0';
  }

  @override
  String get feePlansScreenTitle => 'خطط الرسوم';

  @override
  String get feePlansErrorTitle => 'تعذّر تحميل خطط الرسوم';

  @override
  String feePlansOverdueChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متأخر',
      many: '$count متأخراً',
      few: '$count متأخرون',
      two: 'متأخران',
      one: 'متأخر واحد',
    );
    return '$_temp0';
  }

  @override
  String feePlansPartialChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دفعة جزئية',
      many: '$count دفعة جزئية',
      few: '$count دفعات جزئية',
      two: 'دفعان جزئيان',
      one: 'دفع جزئي واحد',
    );
    return '$_temp0';
  }

  @override
  String feePlansPaidChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدفوعة',
      many: '$count مدفوعة',
      few: '$count مدفوعات',
      two: 'مدفوعتان',
      one: 'مدفوعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String feePlansAmountLine(String currency, String total, String outstanding) {
    return '$currency $total الإجمالي · مستحقة $currency $outstanding';
  }

  @override
  String feePlansAmountOnly(String currency, String total) {
    return '$currency $total';
  }

  @override
  String get feePlanDetailTitle => 'خطة الرسوم';

  @override
  String get feePlanLoadingTitle => 'جارٍ تحميل خطة الرسوم';

  @override
  String get feePlanLoadingMessage => 'نبحث عن تفصيل البنود وحالة الدفع.';

  @override
  String get feePlanErrorTitle => 'تعذّر تحميل خطة الرسوم';

  @override
  String get feePlanNotFoundTitle => 'خطة الرسوم غير موجودة';

  @override
  String get feePlanNotFoundMessage =>
      'لم نعثر على خطة الرسوم هذه في الكتالوج الحالي. ربما أُلغيت أو نُقلت إلى عام دراسي مختلف؛ ارجع إلى القائمة لرؤية آخر الخطط.';

  @override
  String get feePlanNotFoundAction => 'العودة إلى خطط الرسوم';

  @override
  String get feePlanNoBreakdownMessage =>
      'لم يُرجع الخادم تفصيل البنود لهذه الخطة. المبلغ الإجمالي ظاهر أعلاه؛ ستظهر قائمة البنود عند إضافة التفصيل على الخادم.';

  @override
  String feePlanIdentitySubtitle(String id) {
    return 'خطة الرسوم $id';
  }

  @override
  String feePlanDueDateChip(String date) {
    return 'الاستحقاق $date';
  }

  @override
  String get feePlanTotalLabel => 'الإجمالي';

  @override
  String get feePlanPaidLabel => 'المدفوع';

  @override
  String get feePlanOutstandingLabel => 'المستحق';

  @override
  String get feeOperationsScreenTitle => 'عمليات الرسوم';

  @override
  String get feeOperationsLoadingTitle => 'جارٍ تحميل العمليات';

  @override
  String get feeOperationsLoadingMessage =>
      'نجمع أحدث إجماليات الفواتير والمدفوعات.';

  @override
  String get feeOperationsErrorTitle => 'تعذّر تحميل العمليات';

  @override
  String get feeOperationsCollectionRate => 'معدل التحصيل';

  @override
  String get feeOperationsNoInvoices => 'لا توجد فواتير بعد';

  @override
  String get feeOperationsNoInvoicesMessage =>
      'لم تُصدر المدرسة أي فواتير بعد. سيظهر المعدل بمجرد نشر الخطة الأولى.';

  @override
  String feeOperationsCollectedOfTotal(String collectedCurrency,
      String collectedAmount, String totalCurrency, String totalAmount) {
    return 'تم تحصيل $collectedCurrency $collectedAmount من $totalCurrency $totalAmount حتى الآن.';
  }

  @override
  String get feeOperationsInvoiced => 'مُصدرة';

  @override
  String get feeOperationsInvoicedSub => 'إجمالي المُصدَر في هذه الفترة';

  @override
  String get feeOperationsCollected => 'محصلة';

  @override
  String get feeOperationsCollectedSub => 'إجمالي المُحصَّل حتى الآن';

  @override
  String get feeOperationsOutstanding => 'مستحقة';

  @override
  String get feeOperationsOutstandingSub => 'لا تزال مستحقة';

  @override
  String get feeOperationsByStatus => 'حسب الحالة';

  @override
  String feeOperationsPaidCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدفوعة',
      many: '$count مدفوعة',
      few: '$count مدفوعات',
      two: 'مدفوعتان',
      one: 'مدفوعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String feeOperationsOverdueCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متأخرة',
      many: '$count متأخرة',
      few: '$count متأخرات',
      two: 'متأخرتان',
      one: 'متأخرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String feeOperationsDraftCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسودة',
      many: '$count مسودة',
      few: '$count مسودات',
      two: 'مسودتان',
      one: 'مسودة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get feeOperationsViewPlansAction => 'عرض خطط الرسوم';

  @override
  String get operationsScreenTitle => 'العمليات';

  @override
  String get operationsTabHealth => 'الصحة';

  @override
  String get operationsTabDelivery => 'التسليم';

  @override
  String get operationsTabAudit => 'التدقيق';

  @override
  String get operationsLoadingTitle => 'جارٍ تحميل صحة العمليات';

  @override
  String get operationsLoadingMessage =>
      'نجمع أحدث لقطة لمؤشرات الأداء لكل وحدة.';

  @override
  String get operationsErrorTitle => 'تعذّر تحميل العمليات';

  @override
  String get operationsSystemHealth => 'صحة النظام';

  @override
  String get operationsStatusHealthy => 'سليم';

  @override
  String get operationsStatusDegraded => 'متراجع';

  @override
  String get operationsStatusUnhealthy => 'غير سليم';

  @override
  String operationsGeneratedAt(String timestamp) {
    return 'أُنشئ في $timestamp';
  }

  @override
  String get operationsModulesHeader => 'مؤشرات لكل وحدة';

  @override
  String get operationsModulesEmptyTitle => 'لا توجد مؤشرات بعد';

  @override
  String get operationsModulesEmptyMessage =>
      'لم يُبلّغ الخادم عن أي مؤشرات لكل وحدة. ستظهر هنا بمجرد ورود أول لقطة.';

  @override
  String get operationsModuleAnalytics => 'التحليلات';

  @override
  String get operationsModuleAudit => 'التدقيق';

  @override
  String get operationsModuleDelivery => 'التسليم';

  @override
  String get operationsModuleImports => 'الاستيراد';

  @override
  String get operationsModuleOutbox => 'الصندوق الصادر';

  @override
  String get operationsDeliveryLoadingTitle => 'جارٍ تحميل صحة التسليم';

  @override
  String get operationsDeliveryLoadingMessage =>
      'نجمع إحصائيات التسليم حسب الحالة.';

  @override
  String get operationsDeliveryByStatus => 'حسب الحالة';

  @override
  String get operationsDeliveryEmptyTitle => 'لا توجد عمليات تسليم بعد';

  @override
  String get operationsDeliveryEmptyMessage =>
      'قائمة التسليم فارغة. ستظهر الإحصائيات هنا بمجرد أن يبدأ الخادم بإرسال الأحداث.';

  @override
  String get operationsDeliveryTotal => 'إجمالي عمليات التسليم';

  @override
  String get operationsDeliveryTotalSubtitle => 'عبر جميع الحالات لهذه الفترة';

  @override
  String get operationsAuditLoadingTitle => 'جارٍ تحميل أحداث التدقيق';

  @override
  String get operationsAuditLoadingMessage =>
      'نجلب أحدث أحداث الدخول / الخروج / التحديث / الجهاز.';

  @override
  String get operationsAuditEmptyTitle => 'لا توجد أحداث تدقيق بعد';

  @override
  String get operationsAuditEmptyMessage =>
      'سجل تدقيق المصادقة فارغ. ستظهر الأحداث هنا مع استخدام المدرسة للتطبيق.';

  @override
  String get operationsAuditUnknownUser => 'مستخدم غير معروف';

  @override
  String operationsAuditFromIp(String ip) {
    return 'من $ip';
  }

  @override
  String get governanceScreenTitle => 'الحوكمة';

  @override
  String get governanceLoadingTitle => 'جارٍ تحميل طلبات الخصوصية';

  @override
  String get governanceLoadingMessage =>
      'نجمع أحدث قائمة للخصوصية والحجز القانوني.';

  @override
  String get governanceErrorTitle => 'تعذّر تحميل طلبات الخصوصية';

  @override
  String get governanceEmptyTitle => 'لا توجد طلبات خصوصية';

  @override
  String get governanceEmptyMessage =>
      'القائمة فارغة. عندما يقدم ولي أمر أو موظف طلبًا (تصدير بيانات / حذف / موافقة / حجز قانوني)، سيظهر هنا للمراجعة.';

  @override
  String governanceQueueHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب خصوصية',
      many: '$count طلباً للخصوصية',
      few: '$count طلبات خصوصية',
      two: 'طلبا خصوصية',
      one: 'طلب خصوصية واحد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String governanceLegalHoldCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حالة حجز',
      many: '$count حالة حجز',
      few: '$count حالات حجز',
      two: 'حالتا حجز',
      one: 'حالة حجز واحدة',
      zero: 'لا توجد حالات حجز',
    );
    return '$_temp0';
  }

  @override
  String get governanceLegalHoldChip => 'حجز قانوني';

  @override
  String get governanceUnknownSubject => 'موضوع غير معروف';

  @override
  String get governanceActionsTitle => 'إجراءات الطلب';

  @override
  String get governanceActionProcess => 'وضع تحت المراجعة';

  @override
  String get governanceActionProcessDescription =>
      'نقل هذا الطلب إلى \"قيد المراجعة\" ليعرف الفريق أنه قيد المعالجة.';

  @override
  String get governanceActionApprove => 'الموافقة على الطلب';

  @override
  String get governanceActionApproveDescription =>
      'الموافقة على هذا الطلب. سيتم إخطار مقدم الطلب وتسجيل الإجراء.';

  @override
  String get governanceActionSetHold => 'فرض حجز قانوني';

  @override
  String get governanceActionSetHoldDescription =>
      'وضع هذا الطلب تحت حجز قانوني. ستبقى البيانات محفوظة حتى يُرفع الحجز.';

  @override
  String get governanceActionReleaseHold => 'رفع الحجز القانوني';

  @override
  String get governanceActionReleaseHoldDescription =>
      'رفع الحجز القانوني. يمكن بعد ذلك الموافقة على الطلب أو رفضه.';

  @override
  String get governanceActionSuccess => 'تم تطبيق الإجراء.';

  @override
  String get governanceEvaluateRetentionTooltip => 'تشغيل تقييم الاحتفاظ';

  @override
  String get governanceEvaluateRetentionSuccess => 'بدأ تقييم الاحتفاظ.';

  @override
  String get governanceEvaluateRetentionFailure => 'تعذّر بدء تقييم الاحتفاظ.';

  @override
  String get gradingScreenTitle => 'الدرجات';

  @override
  String get gradingTabOverview => 'نظرة عامة';

  @override
  String get gradingTabPolicies => 'السياسات';

  @override
  String get gradingLoadingTitle => 'جارٍ تحميل بيانات الدرجات';

  @override
  String get gradingLoadingMessage =>
      'نجمع أحدث سجلات الدرجات وكتالوج السياسات.';

  @override
  String get gradingErrorTitle => 'تعذّر تحميل بيانات الدرجات';

  @override
  String get gradingKpiTotal => 'إجمالي الدرجات';

  @override
  String get gradingKpiTotalSubtitle =>
      'كل سجلات الدرجات (المنشورة + المسودات)';

  @override
  String get gradingKpiPublished => 'منشورة';

  @override
  String get gradingKpiPublishedSubtitle => 'تم ترقيتها إلى سجل درجات';

  @override
  String get gradingKpiDraft => 'مسودة';

  @override
  String get gradingKpiDraftSubtitle => 'لا تزال بانتظار النشر';

  @override
  String get gradingKpiAverage => 'المتوسط';

  @override
  String get gradingKpiAverageSubtitle => 'متوسط المنشور على مستوى المدرسة';

  @override
  String get gradingWorkflowHeader => 'سير العمل';

  @override
  String get gradingFeatureHeader => 'الميزة';

  @override
  String gradingFeatureValue(String feature) {
    return 'الميزة: $feature';
  }

  @override
  String gradingCoverageValue(String coverage) {
    return 'التغطية: $coverage';
  }

  @override
  String gradingRecentStudentsValue(String value) {
    return 'الطلاب الأخيرون: $value';
  }

  @override
  String gradingPassThresholdValue(String pct) {
    return 'النجاح ≥ $pct٪';
  }

  @override
  String get gradingPermissionsHeader => 'الأذونات';

  @override
  String gradingPermissionsDoctypesValue(String doctypes) {
    return 'يدير: $doctypes';
  }

  @override
  String get gradingPermissionsReadRoles => 'أدوار القراءة';

  @override
  String get gradingPermissionsRequiredRoles => 'الأدوار المطلوبة للموافقة';

  @override
  String get loginScreenTitle => 'لاراتيك سكولز';

  @override
  String get loginSignInSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get loginOAuthPkceTitle => 'OAuth + PKCE';

  @override
  String get loginOAuthPkceMessage =>
      'S256، عرض ويب داخل التطبيق، إعادة توجيه عبر وسيط النظام.';

  @override
  String get loginSsoChip => 'Laratik SSO';

  @override
  String get loginButton => 'تسجيل الدخول عبر لاراتيك';

  @override
  String get loginButtonLoading => 'جارٍ فتح المتصفح…';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsFilterAll => 'الكل';

  @override
  String get notificationsFilterUnread => 'غير المقروءة';

  @override
  String get notificationsLoadingTitle => 'جارٍ تحميل الإشعارات';

  @override
  String get notificationsLoadingMessage => 'نجلب أحدث صندوق الوارد من الخادم.';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyMessage => 'أنت على اطلاع بكل شيء.';

  @override
  String get notificationsErrorTitle => 'تعذّر تحميل الإشعارات';

  @override
  String get studentsTitle => 'الطلاب';

  @override
  String get studentsNewButton => 'طالب جديد';

  @override
  String get studentsSearchPlaceholder => 'البحث بالاسم أو رقم الطالب';

  @override
  String get studentsFilterByGrade => 'تصفية حسب الصف';

  @override
  String get studentsFilterByClassGroup => 'تصفية حسب المجموعة الصفية';

  @override
  String get studentsGradeFilterChip => 'الصف';

  @override
  String get studentsClassGroupFilterChip => 'المجموعة الصفية';

  @override
  String get studentsFilterClear => 'مسح';

  @override
  String get studentsFilterApply => 'تطبيق';

  @override
  String get studentsLoadingTitle => 'جارٍ تحميل الطلاب';

  @override
  String get studentsLoadingMessage => 'نجلب أحدث قائمة من الخادم.';

  @override
  String get studentsEmptyTitle => 'لا يوجد طلاب بعد';

  @override
  String get studentsEmptyMessage =>
      'عندما تضيف طالبًا إلى القائمة، سيظهر هنا.';

  @override
  String get studentsNoMatchTitle => 'لا يوجد طلاب يطابقون التصفية الحالية';

  @override
  String get studentsNoMatchMessage => 'جرّب مسح البحث أو تصفية الصف.';

  @override
  String get studentsErrorTitle => 'تعذّر تحميل الطلاب';

  @override
  String get studentsAddStudentButton => 'إضافة طالب';

  @override
  String get studentsFirstStudentMessage => 'أضف أول طالب للبدء.';

  @override
  String get dataImportsScreenTitle => 'استيراد البيانات';

  @override
  String get dataImportsTabBatches => 'الدفعات';

  @override
  String get dataImportsTabScoreImports => 'استيراد الدرجات';

  @override
  String get dataImportsLoadingTitle => 'جارٍ تحميل استيراد البيانات';

  @override
  String get dataImportsLoadingMessage =>
      'يجري جلب أحدث الدفعات واستيرادات الدرجات من الخادم.';

  @override
  String get dataImportsErrorTitle => 'تعذّر تحميل استيراد البيانات';

  @override
  String get dataImportsBatchesEmptyTitle => 'لا توجد دفعات استيراد بيانات بعد';

  @override
  String get dataImportsBatchesEmptyMessage =>
      'عند رفع حزمة (عبر سطح المكتب أو معالج الجوال المستقبلي)، ستظهر هنا.';

  @override
  String get dataImportsScoreEmptyTitle => 'لا توجد استيرادات درجات بعد';

  @override
  String get dataImportsScoreEmptyMessage =>
      'عند رفع ملف درجات (عبر سطح المكتب أو معالج الجوال المستقبلي)، ستظهر هنا.';

  @override
  String dataImportsHashChip(String hash) {
    return 'التجزئة $hash';
  }

  @override
  String dataImportsRowCountChip(String doctype, int count) {
    return '$doctype · $count';
  }

  @override
  String dataImportsBatchCreatedAt(String when) {
    return 'تاريخ الرفع $when';
  }

  @override
  String dataImportsScoreCreatedAt(String when) {
    return 'تاريخ الرفع $when';
  }

  @override
  String get dataImportsBatchDetailTitle => 'مطابقة الدفعة';

  @override
  String get dataImportsBatchFallbackHeader => 'جارٍ تحميل ملخص الدفعة…';

  @override
  String dataImportsReconciliationHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف',
      many: '$count صفًا',
      few: '$count صفوف',
      two: 'صفّان',
      one: 'صف واحد',
      zero: 'لا توجد صفوف',
    );
    return '$_temp0';
  }

  @override
  String get dataImportsReconciliationEmptyTitle => 'لا توجد صفوف للمطابقة';

  @override
  String get dataImportsReconciliationEmptyMessage =>
      'لا تحتوي هذه الدفعة على قرارات لكل صف للمراجعة.';

  @override
  String get dataImportsReconciliationDoctypeFallback => 'صف غير مصنّف';

  @override
  String dataImportsReconciliationRowIndex(int index) {
    return 'الصف $index';
  }

  @override
  String dataImportsPayloadChip(String key, String value) {
    return '$key · $value';
  }

  @override
  String get dataImportsScoreDetailTitle => 'استيراد الدرجات';

  @override
  String get dataImportsScoreNotFoundTitle => 'استيراد الدرجات غير موجود';

  @override
  String get dataImportsScoreNotFoundMessage =>
      'استيراد الدرجات هذا لم يعد ضمن كتالوج المدرسة.';

  @override
  String dataImportsScoreColumnsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عمود',
      many: '$count عمودًا',
      few: '$count أعمدة',
      two: 'عمودان',
      one: 'عمود واحد',
      zero: 'لا توجد أعمدة',
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
      other: '$count عمود',
      many: '$count عمودًا',
      few: '$count أعمدة',
      two: 'عمودان',
      one: 'عمود واحد',
    );
    return '$_temp0';
  }

  @override
  String get dataImportsScoreCountsHeader => 'عدادات التحقق';

  @override
  String dataImportsScoreCountChip(String key, String value) {
    return '$key · $value';
  }

  @override
  String get dataImportsScoreValidateAction => 'تحقّق';

  @override
  String get dataImportsScoreCommitAction => 'اعتماد';

  @override
  String get dataImportsScoreValidatedSnack => 'تم التحقق من استيراد الدرجات.';

  @override
  String get dataImportsScoreCommittedSnack => 'تم اعتماد استيراد الدرجات.';

  @override
  String dataImportsScoreErrorSnack(String message) {
    return 'فشل الإجراء: $message';
  }

  @override
  String get homeAdminDataImports => 'استيراد البيانات';

  @override
  String get homeAdminDataImportsSubtitle =>
      'مراجعة الدفعات واستيرادات الدرجات';

  @override
  String get homeTeacherExams => 'الاختبارات';

  @override
  String get homeTeacherExamsSubtitle =>
      'إنشاء خطط الاختبارات + تصحيح المحاولات';

  @override
  String get teacherExamsScreenTitle => 'الاختبارات';

  @override
  String get teacherExamsLoadingTitle => 'جارٍ تحميل الاختبارات';

  @override
  String get teacherExamsLoadingMessage => 'يجري جلب خطط اختباراتك من الخادم.';

  @override
  String get teacherExamsErrorTitle => 'تعذّر تحميل الاختبارات';

  @override
  String get teacherExamsEmptyTitle => 'لا توجد خطط اختبارات بعد';

  @override
  String get teacherExamsEmptyMessage => 'عند إنشاء اختبار، سيظهر هنا.';

  @override
  String teacherExamsDurationChip(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes دقيقة',
      many: '$minutes دقيقة',
      few: '$minutes دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String teacherExamsMaxScoreChip(int score) {
    return 'الحد الأقصى $score';
  }

  @override
  String get teacherExamDetailTitle => 'خطة الاختبار';

  @override
  String get teacherExamNotFoundTitle => 'خطة الاختبار غير موجودة';

  @override
  String get teacherExamNotFoundMessage =>
      'خطة الاختبار هذه لم تعد ضمن كتالوج المدرسة.';

  @override
  String get teacherExamStatusPublished => 'منشور';

  @override
  String get teacherExamStatusClosed => 'مغلق';

  @override
  String get teacherExamStatusDraft => 'مسودة';

  @override
  String teacherExamDateChip(String date) {
    return 'التاريخ $date';
  }

  @override
  String teacherExamMarksChip(int marks) {
    String _temp0 = intl.Intl.pluralLogic(
      marks,
      locale: localeName,
      other: '$marks درجة',
      many: '$marks درجة',
      few: '$marks درجات',
      two: 'درجتان',
      one: 'درجة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get teacherExamQuestionsHeader => 'الأسئلة';

  @override
  String get teacherExamQuestionsEmptyTitle => 'لا توجد أسئلة';

  @override
  String get teacherExamQuestionsEmptyMessage =>
      'كتالوج أسئلة المادة فارغ. أضف الأسئلة عبر سطح المكتب، أو معالج الجوال المستقبلي.';

  @override
  String get teacherExamQuestionFallback => 'سؤال بلا عنوان';

  @override
  String teacherExamQuestionTypeChip(String type) {
    return 'النوع: $type';
  }

  @override
  String get teacherExamManualGradeAction => 'إدخال درجة يدويًا';

  @override
  String get manualGradeScreenTitle => 'تصحيح يدوي';

  @override
  String get manualGradeAttemptHeader => 'المحاولة';

  @override
  String get manualGradeAttemptLabel => 'معرّف المحاولة';

  @override
  String get manualGradeAttemptHint =>
      'الصق معرّف المحاولة من إشعار أو من سطح المكتب';

  @override
  String get manualGradeAttemptRequired => 'معرّف المحاولة مطلوب';

  @override
  String manualGradeScoresHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سؤال',
      many: '$count سؤالًا',
      few: '$count أسئلة',
      two: 'سؤالان',
      one: 'سؤال واحد',
      zero: 'لا توجد أسئلة',
    );
    return '$_temp0';
  }

  @override
  String get manualGradeScoresEmptyTitle => 'لا توجد أسئلة';

  @override
  String get manualGradeScoresEmptyMessage => 'أضف أسئلة إلى هذه الخطة أولًا.';

  @override
  String get manualGradeScoreLabel => 'الدرجة';

  @override
  String manualGradeScoreHint(int max) {
    return '0 – $max';
  }

  @override
  String get manualGradeScoreRequired => 'الدرجة مطلوبة';

  @override
  String get manualGradeScoreInvalid => 'أدخل رقمًا صالحًا';

  @override
  String get manualGradeScoreNegative => 'لا يمكن أن تكون الدرجة سالبة';

  @override
  String manualGradeScoreOverMax(int max) {
    return 'لا يمكن أن تتجاوز الدرجة $max';
  }

  @override
  String get manualGradeSubmitAction => 'اعتماد الدرجة';

  @override
  String get manualGradeSubmitLoading => 'جارٍ الاعتماد…';

  @override
  String manualGradeSuccessSnack(double score) {
    return 'تم تصحيح المحاولة. المجموع الجديد: $score';
  }

  @override
  String get manualGradeSuccessSnackNoScore => 'تم تصحيح المحاولة.';

  @override
  String manualGradeErrorSnack(String message) {
    return 'فشل التصحيح: $message';
  }

  @override
  String get teacherExamAddQuestionAction => 'إضافة سؤال';

  @override
  String get teacherExamPublishAction => 'اعتماد الاختبار';

  @override
  String get teacherExamPublishLoading => 'جارٍ الاعتماد…';

  @override
  String get teacherExamPublishedSnack => 'تم اعتماد الاختبار.';

  @override
  String teacherExamPublishErrorSnack(String message) {
    return 'فشل الاعتماد: $message';
  }

  @override
  String get teacherExamQuestionPublishAction => 'اعتماد';

  @override
  String get teacherExamQuestionPublishLoading => 'جارٍ الاعتماد…';

  @override
  String get teacherExamQuestionPublishedSnack => 'تم اعتماد السؤال.';

  @override
  String teacherExamQuestionPublishErrorSnack(String message) {
    return 'فشل الاعتماد: $message';
  }

  @override
  String get teacherExamQuestionFormTitle => 'إضافة سؤال';

  @override
  String get teacherExamQuestionTypeHeader => 'النوع';

  @override
  String get teacherExamQuestionTextHeader => 'نص السؤال';

  @override
  String get teacherExamQuestionTextLabel => 'السؤال';

  @override
  String get teacherExamQuestionTextHint => 'ماذا تريد أن تسأل؟';

  @override
  String get teacherExamQuestionTextRequired => 'نص السؤال مطلوب';

  @override
  String get teacherExamQuestionMarksHeader => 'الدرجة';

  @override
  String get teacherExamQuestionMarksLabel => 'الدرجة';

  @override
  String get teacherExamQuestionMarksHint => '1، 2، 5، …';

  @override
  String get teacherExamQuestionMarksRequired => 'الدرجة مطلوبة';

  @override
  String get teacherExamQuestionMarksInvalid => 'أدخل رقمًا صحيحًا';

  @override
  String get teacherExamQuestionMarksNegative =>
      'يجب أن تكون الدرجة أكبر من صفر';

  @override
  String teacherExamQuestionOptionsHeader(int count) {
    return 'الخيارات ($count)';
  }

  @override
  String get teacherExamQuestionAddOption => 'إضافة خيار';

  @override
  String get teacherExamQuestionSubmitAction => 'حفظ السؤال';

  @override
  String get teacherExamQuestionSubmitLoading => 'جارٍ الحفظ…';

  @override
  String get teacherExamQuestionCreatedSnack => 'تمت إضافة السؤال.';

  @override
  String teacherExamQuestionErrorSnack(String message) {
    return 'فشل الحفظ: $message';
  }
}
