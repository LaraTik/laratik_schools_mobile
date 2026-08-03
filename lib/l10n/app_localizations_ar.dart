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
  String get commonContinue => 'متابعة';

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
  String get homeParentPrivacyRequestTitle => 'تقديم طلب خصوصية';

  @override
  String get homeParentPrivacyRequestSubtitle =>
      'الوصول إلى البيانات أو محوها أو تصحيحها';

  @override
  String get homeStudentPrivacyRequestTitle => 'تقديم طلب خصوصية';

  @override
  String get homeStudentPrivacyRequestSubtitle =>
      'الوصول إلى البيانات أو محوها أو تصحيحها';

  @override
  String get studentDetailScreenTitle => 'الطالب';

  @override
  String get studentDetailErrorTitle => 'تعذّر تحميل الطالب';

  @override
  String get studentDetailLoadingTitle => 'جارٍ تحميل الطالب';

  @override
  String get studentDetailEnrollmentHeader => 'التسجيل الحالي';

  @override
  String get studentDetailIdentityHeader => 'الهوية والتواصل';

  @override
  String get studentDetailGuardiansHeader => 'أولياء الأمور';

  @override
  String get studentDetailRecentGradesHeader => 'الدرجات الأخيرة';

  @override
  String get studentDetailGradeLabel => 'الصف';

  @override
  String get studentDetailClassGroupLabel => 'الفصل';

  @override
  String get studentDetailAcademicYearLabel => 'السنة الدراسية';

  @override
  String get studentDetailStatusLabel => 'الحالة';

  @override
  String get studentDetailEnrollmentStatusLabel => 'حالة التسجيل';

  @override
  String get studentDetailActivationLabel => 'التفعيل';

  @override
  String get studentDetailNationalityLabel => 'الجنسية';

  @override
  String get studentDetailCountryLabel => 'البلد';

  @override
  String get studentDetailErpnextCustomerLabel => 'عميل ERPNext';

  @override
  String get studentDetailNoDataLabel => 'لا توجد بيانات.';

  @override
  String get studentDetailNoGuardianChip => 'لا يوجد ولي أمر مسجّل';

  @override
  String get studentDetailCountryWarningTitle => 'البلد يحتاج مراجعة';

  @override
  String get studentDetailCountryDefaultedMessage =>
      'تم تعيين البلد افتراضيًا من الجنسية؛ يرجى التأكد مع المشغّل.';

  @override
  String get studentDetailCountryMismatchMessage =>
      'الجنسية وبلد الإقامة مختلفان؛ تحقّق قبل إدخال الدرجات.';

  @override
  String get studentCreateScreenTitle => 'طالب جديد';

  @override
  String get studentCreateLoadingTitle => 'جارٍ تحميل النموذج';

  @override
  String get studentCreateLoadingMessage => 'يجري جلب سياق إعداد المدرسة.';

  @override
  String get studentCreateSchemaErrorTitle => 'تعذّر تحميل مخطط النموذج';

  @override
  String get studentCreateSuccessTitle => 'تم إنشاء الطالب';

  @override
  String get studentCreateSuccessFallback => 'سجل الطالب محفوظ.';

  @override
  String get studentCreateCountryDefaultedChip =>
      'تم تعيين البلد افتراضيًا من الجنسية';

  @override
  String get studentCreateCountryMismatchChip => 'البلد ≠ الجنسية';

  @override
  String studentCreateWarningsChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحذير',
      many: '$count تحذيرًا',
      few: '$count تحذيرات',
      two: 'تحذيران',
      one: 'تحذير واحد',
      zero: 'لا تحذيرات',
    );
    return '$_temp0';
  }

  @override
  String get studentCreateAnotherAction => 'إنشاء طالب آخر';

  @override
  String get studentCreateOpenRecordAction => 'فتح السجل';

  @override
  String get studentCreateSubmitAction => 'إنشاء الطالب';

  @override
  String get studentCreateSubmitLoading => 'جارٍ الإنشاء…';

  @override
  String studentCreateRequiredRolesChip(String roles) {
    return 'يتطلب: $roles';
  }

  @override
  String get studentCreateIdentityHeader => 'الهوية';

  @override
  String get studentCreateFirstNameLabel => 'الاسم الأول';

  @override
  String get studentCreateFirstNameHint => 'كما هو مكتوب في شهادة الميلاد';

  @override
  String get studentCreateLastNameLabel => 'اسم العائلة';

  @override
  String get studentCreateDateOfBirthHeader => 'تاريخ الميلاد';

  @override
  String get studentCreateDateOfBirthLabel => 'تاريخ الميلاد';

  @override
  String get studentCreateDateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get studentCreateCountryNationalityHeader => 'البلد والجنسية';

  @override
  String get studentCreateNationalityLabel => 'الجنسية';

  @override
  String get studentCreateNationalityHint => 'الجنسية المسجّلة';

  @override
  String get studentCreateCountryLabel => 'بلد الإقامة';

  @override
  String get studentCreateCountryHint => 'مكان إقامة الطالب';

  @override
  String get studentCreateGuardianHeader => 'ولي الأمر';

  @override
  String get studentCreateGuardianNameLabel => 'اسم ولي الأمر';

  @override
  String get studentCreateGuardianPhoneLabel => 'هاتف ولي الأمر';

  @override
  String get studentCreateEnrollmentHeader => 'التسجيل';

  @override
  String get studentCreateGradeLabel => 'الصف';

  @override
  String get studentCreateGradeHint => 'الصف الأول';

  @override
  String get studentCreateNotesHeader => 'ملاحظات';

  @override
  String get studentCreateNotesLabel => 'ملاحظات';

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

  @override
  String get staffListScreenTitle => 'الموظفون';

  @override
  String get staffListSearchHint => 'ابحث بالاسم أو الدور';

  @override
  String get staffListNewStaffAction => 'موظف جديد';

  @override
  String get staffListLoadingTitle => 'جارٍ تحميل الموظفين';

  @override
  String get staffListLoadingMessage => 'يجري جلب أحدث قائمة من الخادم.';

  @override
  String get staffListEmptyTitle => 'لا يوجد موظفون بعد';

  @override
  String get staffListEmptyFilterTitle =>
      'لا يوجد موظفون يطابقون المرشح الحالي';

  @override
  String get staffListEmptyMessage => 'أضف أول موظف للبدء.';

  @override
  String get staffListEmptyFilterMessage => 'حاول مسح البحث أو مرشح الدور.';

  @override
  String get staffListAddStaffAction => 'إضافة موظف';

  @override
  String get staffListErrorTitle => 'تعذّر تحميل الموظفين';

  @override
  String get staffListFilterRole => 'الدور';

  @override
  String get staffListFilterClear => 'مسح';

  @override
  String get staffListFilterRoleTitle => 'تصفية حسب الدور';

  @override
  String get staffListFilterRoleTeacher => 'معلّم';

  @override
  String get staffListFilterRolePrincipal => 'مدير المدرسة';

  @override
  String get staffListFilterRoleVicePrincipal => 'نائب المدير';

  @override
  String get staffListFilterRoleCounselor => 'مشير';

  @override
  String get staffListFilterRoleLibrarian => 'أمين المكتبة';

  @override
  String get staffListFilterRoleAdmin => 'مسؤول';

  @override
  String get staffDetailScreenTitle => 'الموظف';

  @override
  String get staffDetailLoadingTitle => 'جارٍ تحميل الموظف';

  @override
  String get staffDetailErrorTitle => 'تعذّر تحميل الموظف';

  @override
  String get staffDetailRoleBranchHeader => 'الدور والفرع';

  @override
  String get staffDetailRoleLabel => 'الدور';

  @override
  String get staffDetailBranchLabel => 'الفرع';

  @override
  String get staffDetailStatusLabel => 'الحالة';

  @override
  String get staffDetailDateOfJoiningLabel => 'تاريخ الالتحاق';

  @override
  String get staffDetailUserAccountLabel => 'حساب المستخدم';

  @override
  String get staffDetailIdentityHeader => 'الهوية والتواصل';

  @override
  String get staffDetailGenderLabel => 'الجنس';

  @override
  String get staffDetailNationalityLabel => 'الجنسية';

  @override
  String get staffDetailCountryLabel => 'البلد';

  @override
  String get staffDetailErpnextEmployeeLabel => 'موظف إيربنكست';

  @override
  String get staffDetailNoDataLabel => 'لا توجد بيانات.';

  @override
  String get staffStatusActive => 'نشط';

  @override
  String get staffCreateScreenTitle => 'موظف جديد';

  @override
  String get staffCreateLoadingTitle => 'جارٍ تحميل النموذج';

  @override
  String get staffCreateLoadingMessage => 'يجري جلب إعدادات الموظفين للمدرسة.';

  @override
  String get staffCreateErrorTitle => 'تعذّر تحميل مخطط النموذج';

  @override
  String get staffCreateIdentityHeader => 'الهوية';

  @override
  String get staffCreateFirstNameLabel => 'الاسم الأول';

  @override
  String get staffCreateLastNameLabel => 'الاسم الأخير';

  @override
  String get staffCreateRoleHeader => 'الدور';

  @override
  String get staffCreateRoleLabel => 'الدور';

  @override
  String get staffCreateRoleHint => 'معلّم';

  @override
  String get staffCreateContactHeader => 'التواصل';

  @override
  String get staffCreateEmailLabel => 'البريد الإلكتروني';

  @override
  String get staffCreatePhoneLabel => 'الهاتف';

  @override
  String get staffCreateCountryHeader => 'البلد والجنسية';

  @override
  String get staffCreateNationalityLabel => 'الجنسية';

  @override
  String get staffCreateCountryLabel => 'بلد الإقامة';

  @override
  String get staffCreateDateHeader => 'تاريخ الالتحاق';

  @override
  String get staffCreateDateOfJoiningLabel => 'تاريخ الالتحاق';

  @override
  String get staffCreateDateOfJoiningHint => 'YYYY-MM-DD';

  @override
  String get staffCreateNotesHeader => 'ملاحظات';

  @override
  String get staffCreateNotesLabel => 'ملاحظات';

  @override
  String get staffCreateSuccessTitle => 'تم إنشاء بيان الموظف';

  @override
  String get staffCreateSuccessFallback => 'بيان الموظف موجود.';

  @override
  String staffCreateEmployeeChip(String id) {
    return 'الموظف: $id';
  }

  @override
  String get staffCreateAnotherAction => 'إنشاء موظف آخر';

  @override
  String get staffCreateOpenRecordAction => 'فتح السجل';

  @override
  String get staffCreateSubmitAction => 'إنشاء موظف';

  @override
  String get staffCreateSubmitLoading => 'جارٍ الإنشاء…';

  @override
  String get guardianListScreenTitle => 'أولياء الأمور';

  @override
  String get guardianListSearchHint => 'ابحث بالاسم أو الهاتف أو البريد';

  @override
  String get guardianListNewGuardianAction => 'ولي أمر جديد';

  @override
  String get guardianListLoadingTitle => 'جارٍ تحميل أولياء الأمور';

  @override
  String get guardianListLoadingMessage => 'يجري جلب أحدث قائمة من الخادم.';

  @override
  String get guardianListEmptyTitle => 'لا يوجد أولياء أمور بعد';

  @override
  String get guardianListEmptyFilterTitle =>
      'لا يوجد أولياء أمور يطابقون المرشح الحالي';

  @override
  String get guardianListEmptyMessage => 'أضف أول ولي أمر للبدء.';

  @override
  String get guardianListEmptyFilterMessage =>
      'حاول مسح البحث أو مرشح العلاقة.';

  @override
  String get guardianListAddGuardianAction => 'إضافة ولي أمر';

  @override
  String get guardianListErrorTitle => 'تعذّر تحميل أولياء الأمور';

  @override
  String get guardianListFilterRelation => 'العلاقة';

  @override
  String get guardianListFilterClear => 'مسح';

  @override
  String get guardianListFilterRelationTitle => 'تصفية حسب العلاقة';

  @override
  String get guardianListFilterRelationFather => 'أب';

  @override
  String get guardianListFilterRelationMother => 'أم';

  @override
  String get guardianListFilterRelationBrother => 'أخ';

  @override
  String get guardianListFilterRelationSister => 'أخت';

  @override
  String get guardianListFilterRelationUncle => 'عم/خال';

  @override
  String get guardianListFilterRelationAunt => 'عمة/خالة';

  @override
  String get guardianListFilterRelationGrandparent => 'جد/جدة';

  @override
  String get guardianListFilterRelationOther => 'أخرى';

  @override
  String guardianListLinkedChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طالب',
      many: '$count طالبًا',
      few: '$count طلاب',
      two: 'طالبان',
      one: 'طالب واحد',
      zero: 'لا يوجد طلاب',
    );
    return '$_temp0';
  }

  @override
  String get guardianDetailScreenTitle => 'ولي الأمر';

  @override
  String get guardianDetailLoadingTitle => 'جارٍ تحميل ولي الأمر';

  @override
  String get guardianDetailErrorTitle => 'تعذّر تحميل ولي الأمر';

  @override
  String get guardianDetailLinkedHeader => 'الطلاب المرتبطون';

  @override
  String get guardianDetailContactHeader => 'التواصل';

  @override
  String get guardianDetailPhoneLabel => 'الهاتف';

  @override
  String get guardianDetailEmailLabel => 'البريد الإلكتروني';

  @override
  String get guardianDetailOccupationLabel => 'المهنة';

  @override
  String get guardianDetailAddressHeader => 'العنوان';

  @override
  String get guardianDetailAddressLine1Label => 'سطر العنوان 1';

  @override
  String get guardianDetailAddressLine2Label => 'سطر العنوان 2';

  @override
  String get guardianDetailCityLabel => 'المدينة';

  @override
  String get guardianDetailPostalCodeLabel => 'الرمز البريدي';

  @override
  String get guardianDetailCountryLabel => 'البلد';

  @override
  String get guardianDetailNationalityLabel => 'الجنسية';

  @override
  String get guardianDetailNoDataLabel => 'لا توجد بيانات.';

  @override
  String get guardianCreateScreenTitle => 'ولي أمر جديد';

  @override
  String get guardianCreateLoadingTitle => 'جارٍ تحميل النموذج';

  @override
  String get guardianCreateLoadingMessage =>
      'يجري جلب إعدادات أولياء الأمور للمدرسة.';

  @override
  String get guardianCreateErrorTitle => 'تعذّر تحميل مخطط النموذج';

  @override
  String get guardianCreateIdentityHeader => 'الهوية';

  @override
  String get guardianCreateNameLabel => 'اسم ولي الأمر';

  @override
  String get guardianCreateRelationHeader => 'العلاقة';

  @override
  String get guardianCreateRelationLabel => 'العلاقة';

  @override
  String get guardianCreateRelationHint => 'أب، أم، …';

  @override
  String get guardianCreateContactHeader => 'التواصل';

  @override
  String get guardianCreatePhoneLabel => 'الهاتف';

  @override
  String get guardianCreateEmailLabel => 'البريد الإلكتروني';

  @override
  String get guardianCreateOccupationLabel => 'المهنة';

  @override
  String get guardianCreateAddressHeader => 'العنوان';

  @override
  String get guardianCreateAddressLine1Label => 'سطر العنوان 1';

  @override
  String get guardianCreateAddressLine2Label => 'سطر العنوان 2';

  @override
  String get guardianCreateCityLabel => 'المدينة';

  @override
  String get guardianCreatePostalCodeLabel => 'الرمز البريدي';

  @override
  String get guardianCreateNationalityLabel => 'الجنسية';

  @override
  String get guardianCreateCountryLabel => 'البلد';

  @override
  String get guardianCreateSuccessTitle => 'تم إنشاء ولي الأمر';

  @override
  String get guardianCreateSuccessFallback => 'سجل ولي الأمر موجود.';

  @override
  String get guardianCreateAnotherAction => 'إنشاء ولي أمر آخر';

  @override
  String get guardianCreateOpenRecordAction => 'فتح السجل';

  @override
  String get guardianCreateSubmitAction => 'إنشاء ولي أمر';

  @override
  String get guardianCreateSubmitLoading => 'جارٍ الإنشاء…';

  @override
  String get commonActive => 'نشط';

  @override
  String get commonPrimary => 'رئيسي';

  @override
  String get academicsScreenTitle => 'الأكاديميات';

  @override
  String get academicsNewSubjectAction => 'مادة جديدة';

  @override
  String get academicsTabSubjects => 'المواد';

  @override
  String get academicsTabTimetable => 'الجدول';

  @override
  String get academicsTabBranches => 'الفروع';

  @override
  String get academicsSearchHint => 'ابحث بالاسم أو الرمز أو القسم';

  @override
  String get academicsLoadingSubjects => 'جارٍ تحميل المواد';

  @override
  String get academicsErrorSubjects => 'تعذّر تحميل المواد';

  @override
  String get academicsEmptySubjectsTitle => 'لا توجد مواد بعد';

  @override
  String get academicsEmptySubjectsMessage => 'أضف أول مادة للبدء.';

  @override
  String get academicsAddSubjectAction => 'إضافة مادة';

  @override
  String get academicsLoadingTimetable => 'جارٍ تحميل الجدول';

  @override
  String get academicsErrorTimetable => 'تعذّر تحميل الجدول';

  @override
  String get academicsEmptyTimetableTitle => 'لا توجد حصص في الجدول';

  @override
  String get academicsEmptyTimetableMessage =>
      'لم تنشر المدرسة أي حصص في الجدول بعد.';

  @override
  String get academicsLoadingBranches => 'جارٍ تحميل الفروع';

  @override
  String get academicsErrorBranches => 'تعذّر تحميل الفروع';

  @override
  String get academicsEmptyBranchesTitle => 'لا توجد فروع بعد';

  @override
  String get academicsEmptyBranchesMessage =>
      'أضف أول فرع من وحدة تحكم إدارة المدرسة.';

  @override
  String get subjectCreateScreenTitle => 'مادة جديدة';

  @override
  String get subjectCreateSuccessTitle => 'تم إنشاء المادة';

  @override
  String get subjectCreateBackAction => 'العودة إلى الأكاديميات';

  @override
  String get subjectCreateNameLabel => 'اسم المادة';

  @override
  String get subjectCreateNameHint => 'الرياضيات، العربية، …';

  @override
  String get subjectCreateCodeLabel => 'رمز المادة';

  @override
  String get subjectCreateCodeHint => 'MATH-101';

  @override
  String get subjectCreateDepartmentLabel => 'القسم';

  @override
  String get subjectCreateDepartmentHint => 'العلوم، الإنسانيات، …';

  @override
  String get subjectCreateGradeLevelLabel => 'المستوى الدراسي';

  @override
  String get subjectCreateGradeLevelHint => 'الصف 3';

  @override
  String get subjectCreateCreditHoursLabel => 'ساعات الاعتماد';

  @override
  String get subjectCreateDescriptionLabel => 'الوصف';

  @override
  String get subjectCreateSubmitAction => 'إنشاء مادة';

  @override
  String get subjectCreateSubmitLoading => 'جارٍ الإنشاء…';

  @override
  String get attendanceListScreenTitle => 'الحضور';

  @override
  String get attendanceListCaptureAction => 'تسجيل';

  @override
  String get attendanceListLoadingTitle => 'جارٍ تحميل الحضور';

  @override
  String get attendanceListLoadingMessage => 'يجري جلب أحدث السجلات من الخادم.';

  @override
  String get attendanceListEmptyTitle => 'لا توجد سجلات حضور بعد';

  @override
  String get attendanceListEmptyMessage =>
      'انقر تسجيل لبدء حضور يومي لمجموعة صفية.';

  @override
  String get attendanceListStartCaptureAction => 'بدء التسجيل';

  @override
  String get attendanceListErrorTitle => 'تعذّر تحميل الحضور';

  @override
  String get attendanceListPickClassGroup => 'اختر مجموعة صفية';

  @override
  String attendanceListClassGroupLabel(String name) {
    return 'المجموعة الصفية $name';
  }

  @override
  String get attendanceStatusPresent => 'ح';

  @override
  String get attendanceStatusAbsent => 'غ';

  @override
  String get attendanceStatusLate => 'م';

  @override
  String get attendanceStatusExcused => 'مـ';

  @override
  String get attendanceStatusPresentLong => 'حاضر';

  @override
  String get attendanceStatusAbsentLong => 'غائب';

  @override
  String get attendanceStatusLateLong => 'متأخر';

  @override
  String get attendanceStatusExcusedLong => 'بعذر';

  @override
  String attendanceCaptureTitle(String classGroup) {
    return 'الحضور · $classGroup';
  }

  @override
  String get attendanceCaptureRosterErrorTitle => 'تعذّر تحميل قائمة الصف';

  @override
  String get attendanceCaptureRosterLoadingTitle => 'جارٍ تحميل القائمة';

  @override
  String get attendanceCaptureRosterLoadingMessage =>
      'يجري جلب المجموعة الصفية من الخادم.';

  @override
  String get attendanceCaptureEmptyTitle => 'لا يوجد طلاب في هذه المجموعة';

  @override
  String get attendanceCaptureEmptyMessage =>
      'بمجرد تسجيل الطلاب، يصبح تسجيل الحضور ممكنًا.';

  @override
  String attendanceCaptureCountPresent(int count) {
    return 'ح $count';
  }

  @override
  String attendanceCaptureCountAbsent(int count) {
    return 'غ $count';
  }

  @override
  String attendanceCaptureCountLate(int count) {
    return 'م $count';
  }

  @override
  String attendanceCaptureCountExcused(int count) {
    return 'مـ $count';
  }

  @override
  String get attendanceCaptureMarkAllPresent => 'تعليم الكل حاضرًا';

  @override
  String get attendanceCaptureMarkAllAbsent => 'تعليم الكل غائبًا';

  @override
  String attendanceCaptureSuccessAll(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سجل',
      many: '$count سجلًا',
      few: '$count سجلات',
      two: 'سجلين',
      one: 'سجل واحد',
      zero: 'بدون سجلات',
    );
    return 'تم إرسال $_temp0 لتاريخ $date.';
  }

  @override
  String attendanceCaptureSuccessPartial(int succeeded, int failed, int total) {
    return 'تم إرسال $succeeded، فشل $failed من $total.';
  }

  @override
  String get attendanceCaptureSubmit => 'إرسال الحضور';

  @override
  String get attendanceCaptureResubmit => 'إعادة الإرسال';

  @override
  String get attendanceCaptureSubmitLoading => 'جارٍ الإرسال…';

  @override
  String attendanceGuardianLabel(String name) {
    return 'ولي الأمر: $name';
  }

  @override
  String get examsListScreenTitle => 'الاختبارات';

  @override
  String get examsListLoadingTitle => 'جارٍ تحميل الاختبارات';

  @override
  String get examsListLoadingMessage => 'يجري جلب خطط الاختبارات المنشورة.';

  @override
  String get examsListEmptyTitle => 'لا توجد اختبارات منشورة';

  @override
  String get examsListEmptyMessage => 'عندما ينشر المعلم اختبارًا، سيظهر هنا.';

  @override
  String get examsListErrorTitle => 'تعذّر تحميل الاختبارات';

  @override
  String get examsListStatusOpen => 'مفتوح';

  @override
  String get examsListStatusDraft => 'مسودة';

  @override
  String examsListDurationMinutesChip(int minutes) {
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
  String get examAttemptScreenTitle => 'محاولة الاختبار';

  @override
  String get examAttemptAutosaveArmed => 'الحفظ التلقائي مفعّل';

  @override
  String examAttemptAutosaveSaved(String time) {
    return 'تم الحفظ في $time';
  }

  @override
  String get examAttemptAutosaveFailed => 'فشل الحفظ التلقائي';

  @override
  String get examAttemptEligibilityLoadingTitle => 'جارٍ التحقق من الأهلية';

  @override
  String get examAttemptEligibilityErrorTitle => 'تعذّر التحقق من الأهلية';

  @override
  String get examAttemptIneligibleTitle => 'غير مؤهل';

  @override
  String get examAttemptIneligibleMessage =>
      'يقول الخادم إنه لا يمكنك إجراء هذا الاختبار.';

  @override
  String get examAttemptBackToExams => 'العودة إلى الاختبارات';

  @override
  String get examAttemptAbandonedTitle => 'تم التخلي عن المحاولة';

  @override
  String get examAttemptAbandonedMessage =>
      'لقد تخليت عن هذه المحاولة. وسمها الخادم بأنها متروكة.';

  @override
  String get examAttemptSubmittedTitle => 'تم الإرسال';

  @override
  String get examAttemptSubmittedMessage =>
      'إجاباتك على الخادم. تحقق لاحقًا عند نشر النتيجة.';

  @override
  String get examAttemptStartErrorTitle => 'تعذّر بدء المحاولة';

  @override
  String get examAttemptNoStudentError =>
      'لم يتم تحديد طالب. سجّل الدخول وأعد المحاولة.';

  @override
  String get examAttemptReadyTitle => 'هل أنت مستعد للبدء؟';

  @override
  String get examAttemptResolvingStudent => 'جارٍ تحديد الطالب…';

  @override
  String examAttemptResolveStudentError(String error) {
    return 'تعذّر تحديد الطالب: $error';
  }

  @override
  String examAttemptStudentLabel(String name) {
    return 'الطالب: $name';
  }

  @override
  String get examAttemptAutosaveChip => 'حفظ تلقائي كل 15 ثانية';

  @override
  String get examAttemptResolvingLabel => 'جارٍ التحديد…';

  @override
  String get examAttemptStartAction => 'بدء المحاولة';

  @override
  String get examAttemptNoQuestionsTitle => 'لا توجد أسئلة';

  @override
  String get examAttemptNoQuestionsMessage =>
      'لم يُعد الخادم أي أسئلة لهذه المحاولة.';

  @override
  String get examAttemptAbandon => 'التخلي';

  @override
  String get examAttemptAbandoning => 'جارٍ التخلي…';

  @override
  String get examAttemptSubmit => 'إرسال المحاولة';

  @override
  String get examAttemptSubmitting => 'جارٍ الإرسال…';

  @override
  String get examAttemptAbandonDialogTitle => 'هل تريد التخلي عن المحاولة؟';

  @override
  String get examAttemptAbandonDialogMessage =>
      'سيؤدي ذلك إلى وسم المحاولة على الخادم بأنها متروكة. لا يمكنك استئنافها.';

  @override
  String examAttemptMarksChip(int marks) {
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
  String get examAttemptAnswerHint => 'اكتب إجابتك…';

  @override
  String get gradingCorrectionScreenTitle => 'تصحيح درجة';

  @override
  String get gradingCorrectionLoadingTitle => 'جارٍ تحميل النموذج';

  @override
  String get gradingCorrectionLoadingMessage =>
      'يجري جلب سياق إعداد سجل الدرجة.';

  @override
  String get gradingCorrectionErrorTitle => 'تعذّر تحميل النموذج';

  @override
  String get gradingCorrectionTargetHeader => 'الدرجة المستهدفة';

  @override
  String get gradingCorrectionGradeLabel => 'معرّف الدرجة';

  @override
  String get gradingCorrectionScoresHeader => 'الدرجات';

  @override
  String get gradingCorrectionScoreLabel => 'الدرجة';

  @override
  String get gradingCorrectionScoreHint => '0';

  @override
  String get gradingCorrectionMaxScoreLabel => 'الحد الأقصى';

  @override
  String get gradingCorrectionMaxScoreHint => '100';

  @override
  String get gradingCorrectionReasonHeader => 'السبب';

  @override
  String get gradingCorrectionReasonLabel => 'السبب';

  @override
  String get gradingCorrectionReasonHint => 'لماذا يحتاج هذا التصحيح؟';

  @override
  String get gradingCorrectionSubmitAction => 'تطبيق التصحيح';

  @override
  String get gradingCorrectionSubmitLoading => 'جارٍ التطبيق…';

  @override
  String get gradingCorrectionSuccessTitle => 'تم تصحيح الدرجة';

  @override
  String get gradingCorrectionSuccessFallback => 'سجل الدرجة موجود.';

  @override
  String gradingCorrectionSuccessLabel(String name) {
    return 'تم تصحيح الدرجة $name';
  }

  @override
  String gradingCorrectionScoreChip(double score) {
    return 'الدرجة: $score';
  }

  @override
  String gradingCorrectionMaxScoreChip(double max) {
    return 'الحد: $max';
  }

  @override
  String gradingCorrectionActorChip(String actor) {
    return 'بواسطة $actor';
  }

  @override
  String gradingCorrectionTimestampLabel(String timestamp) {
    return 'تم التصحيح في $timestamp';
  }

  @override
  String get gradingCorrectionAnotherAction => 'تصحيح آخر';

  @override
  String get gradingCorrectionBackAction => 'العودة إلى الدرجات';

  @override
  String get gradingCorrectionAction => 'تصحيح درجة';

  @override
  String get gradingCorrectionPromptTitle => 'تصحيح درجة';

  @override
  String get gradingCorrectionPromptHint =>
      'أدخل معرّف الدرجة (مثال: GR-00001)';

  @override
  String get operationsReplayAction => 'إعادة تشغيل';

  @override
  String get operationsReceiveCallbackAction => 'استلام رد الاتصال';

  @override
  String get operationsReplayPromptTitle => 'إعادة تشغيل حدث تسليم';

  @override
  String get operationsReplayEventKeyLabel => 'مفتاح الحدث';

  @override
  String get operationsReplayEventKeyHint =>
      'مثال: comm-delivery-2026-08-01-abc';

  @override
  String get operationsReplayReasonLabel => 'السبب (اختياري)';

  @override
  String get operationsReplayReasonHint => 'لماذا يلزم إعادة التشغيل؟';

  @override
  String operationsReplaySuccessSnack(String key) {
    return 'تمت إعادة تشغيل الحدث $key.';
  }

  @override
  String operationsReplayStatusSnack(String status) {
    return 'حالة إعادة التشغيل: $status.';
  }

  @override
  String operationsReplayErrorSnack(String message) {
    return 'فشلت إعادة التشغيل: $message';
  }

  @override
  String get operationsReceiveCallbackPromptTitle => 'استلام رد اتصال تسليم';

  @override
  String get operationsReceiveCallbackProviderLabel => 'المزود';

  @override
  String get operationsReceiveCallbackProviderHint =>
      'مثال: stripe / sendgrid / fcm';

  @override
  String get operationsReceiveCallbackSignatureLabel => 'التوقيع (اختياري)';

  @override
  String get operationsReceiveCallbackSignatureHint => 'قيمة رأس X-Signature';

  @override
  String get operationsReceiveCallbackBodyLabel => 'المحتوى (اختياري)';

  @override
  String get operationsReceiveCallbackBodyHint =>
      'محتوى رد الاتصال (JSON / نموذج)';

  @override
  String operationsReceiveCallbackSuccessSnack(String key) {
    return 'تم استلام رد الاتصال لـ $key.';
  }

  @override
  String operationsReceiveCallbackStatusSnack(String status) {
    return 'حالة رد الاتصال: $status.';
  }

  @override
  String operationsReceiveCallbackErrorSnack(String message) {
    return 'فشل رد الاتصال: $message';
  }

  @override
  String get privacyRequestSubmitScreenTitle => 'تقديم طلب خصوصية';

  @override
  String get privacyRequestSubmitTypeHeader => 'نوع الطلب';

  @override
  String get privacyRequestTypeAccess => 'الوصول إلى البيانات';

  @override
  String get privacyRequestTypeRectification => 'التصحيح';

  @override
  String get privacyRequestTypeErasure => 'المحو';

  @override
  String get privacyRequestTypeConsentWithdrawal => 'سحب الموافقة';

  @override
  String get privacyRequestTypeLegalHold => 'الاحتجاز القانوني';

  @override
  String get privacyRequestSubmitCategoriesHeader => 'فئات البيانات';

  @override
  String get privacyRequestSubmitAuthorityHeader => 'المرجع';

  @override
  String get privacyRequestSubmitAuthorityLabel => 'مرجع السلطة';

  @override
  String get privacyRequestSubmitAuthorityHint =>
      'مثال: معرّف تذكرة أو معرّف رسالة بريد';

  @override
  String get privacyRequestSubmitAuthorityRequired => 'مرجع السلطة مطلوب.';

  @override
  String get privacyRequestSubmitBranchHeader => 'فرع المدرسة';

  @override
  String get privacyRequestSubmitBranchLabel => 'فرع المدرسة';

  @override
  String get privacyRequestSubmitBranchHint => 'مثال: main / north / campus-2';

  @override
  String get privacyRequestSubmitBranchRequired => 'فرع المدرسة مطلوب.';

  @override
  String get privacyRequestSubmitNoteHeader => 'ملاحظة (اختياري)';

  @override
  String get privacyRequestSubmitNoteLabel => 'ملاحظة';

  @override
  String get privacyRequestSubmitNoteHint => 'لماذا هذا الطلب مطلوب؟';

  @override
  String get privacyRequestSubmitAction => 'إرسال الطلب';

  @override
  String get privacyRequestSubmitLoading => 'جارٍ الإرسال…';

  @override
  String get privacyRequestSubmitSummaryHeader => 'سياق الطلب';

  @override
  String get privacyRequestSubmitSummaryRequester => 'نوع مقدم الطلب';

  @override
  String get privacyRequestSubmitSummarySubject => 'الموضوع';

  @override
  String get privacyRequestSubmitSummaryBranch => 'فرع المدرسة';

  @override
  String get privacyRequestSubmitSuccessTitle => 'تم تقديم طلب الخصوصية';

  @override
  String get privacyRequestSubmitSuccessFallback => 'الطلب موجود.';

  @override
  String privacyRequestSubmitSuccessLabel(String id) {
    return 'تم تقديم الطلب $id.';
  }

  @override
  String get privacyRequestSubmitBackAction => 'العودة إلى عائلتي';

  @override
  String get privacyRequestCategoryPersonal => 'الشخصية';

  @override
  String get privacyRequestCategoryAttendance => 'الحضور';

  @override
  String get privacyRequestCategoryGrades => 'الدرجات';

  @override
  String get privacyRequestCategoryFees => 'الرسوم';

  @override
  String get privacyRequestCategoryHealth => 'الصحة';

  @override
  String get privacyRequestCategoryCommunications => 'التواصل';
}
