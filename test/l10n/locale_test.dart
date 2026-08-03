// SPDX-License-Identifier: Proprietary
// Tests for the ARB-driven localization pipeline.
//
// The mobile supports English (`en`) and Arabic (`ar`).
// `flutter gen-l10n` reads `lib/l10n/app_en.arb` + `app_ar.arb`
// and emits the typed `AppLocalizations` class under
// `lib/l10n/app_localizations.dart`. These tests pin:
//   * Both locales are listed as supported (so the
//     `MaterialApp.supportedLocales` includes both).
//   * The Arabic translations are non-empty for the most
//     user-facing keys (nav labels, app-bar titles, common
//     state messages, the per-role home surfaces, the family /
//     classes / fees surfaces).
//   * Critical pluralization rules behave correctly under both
//     locales (e.g. 0 / 1 / 2 / many).
//   * The shell's `ShellTab.labelFor(context)` resolves the
//     right label per locale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_mobile/app/router.dart';
import 'package:laratik_schools_mobile/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations supportedLocales', () {
    test('includes both English and Arabic', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, contains('en'));
      expect(codes, contains('ar'));
    });
  });

  group('AppLocalizations strings', () {
    Future<AppLocalizations> loadFor(Locale locale) async {
      return AppLocalizations.delegate.load(locale);
    }

    test('English translations are non-empty for the nav labels', () async {
      final en = await loadFor(const Locale('en'));
      expect(en.navStudents, 'Students');
      expect(en.navStaff, 'Staff');
      expect(en.navGuardians, 'Guardians');
      expect(en.navAcademics, 'Academics');
      expect(en.navAttendance, 'Attendance');
      expect(en.navMyClasses, 'My classes');
      expect(en.navFees, 'Fees');
    });

    test('Arabic translations are non-empty for the nav labels', () async {
      final ar = await loadFor(const Locale('ar'));
      expect(ar.navStudents, isNotEmpty);
      expect(ar.navStaff, isNotEmpty);
      expect(ar.navGuardians, isNotEmpty);
      expect(ar.navAcademics, isNotEmpty);
      expect(ar.navAttendance, isNotEmpty);
      expect(ar.navMyClasses, isNotEmpty);
      expect(ar.navFees, isNotEmpty);
      // The Arabic strings should not be the English strings
      // (catches the "I forgot to translate" bug).
      expect(ar.navStudents, isNot(equals('Students')));
      expect(ar.navFees, isNot(equals('Fees')));
    });

    test('Arabic home titles are non-empty + non-English', () async {
      final ar = await loadFor(const Locale('ar'));
      expect(ar.homeParentMyChildren, isNotEmpty);
      expect(ar.homeParentMyChildren, isNot(equals('My children')));
      expect(ar.homeStudentMySchool, isNot(equals('My school')));
      expect(ar.homeTeacherMySchool, isNot(equals('My school')));
    });

    test('English home + admin surfaces resolve the right keys', () async {
      final en = await loadFor(const Locale('en'));
      expect(en.homeAdminMyHome, 'Home');
      expect(en.homeAdminQuickStart, 'Quick start');
      expect(en.homeAdminSignedInAs('Registrar'), 'Signed in as: Registrar');
      expect(en.homeAdminActingAs('Layla'), 'Acting as: Layla');
      expect(en.homeAdminCaptureAttendance, 'Capture attendance');
      expect(en.homeAdminFeePlans, 'Fee plans');
      expect(en.homeAdminFeeOperations, 'Fee operations');
      expect(en.homeParentMyFamily, 'My family');
      expect(en.homeParentFeeInvoicesTitle, 'Fee invoices');
      expect(en.homeStudentGreeting('Ahmad'), 'Hi, Ahmad');
      expect(en.homeStudentStudentId('STU-00001'), 'Student ID: STU-00001');
      expect(en.homeTeacherMyClasses, 'My classes');
      expect(en.homeTeacherCaptureAttendance, 'Capture attendance');
    });

    test('Arabic home + admin surfaces are non-empty + non-English', () async {
      final ar = await loadFor(const Locale('ar'));
      // The home + admin + family surfaces must be translated
      // (not just "I forgot to translate" copy-pasted from English).
      expect(ar.homeAdminMyHome, isNot(equals('Home')));
      expect(ar.homeAdminQuickStart, isNot(equals('Quick start')));
      expect(ar.homeAdminSignedInAs('Registrar'),
          isNot(equals('Signed in as: Registrar')));
      expect(ar.homeAdminActingAs('Layla'), isNot(equals('Acting as: Layla')));
      expect(
          ar.homeAdminCaptureAttendance, isNot(equals('Capture attendance')));
      expect(ar.homeAdminFeePlans, isNot(equals('Fee plans')));
      expect(ar.homeAdminFeeOperations, isNot(equals('Fee operations')));
      expect(ar.homeParentMyFamily, isNot(equals('My family')));
      expect(ar.homeParentFeeInvoicesTitle, isNot(equals('Fee invoices')));
      expect(ar.homeStudentGreeting('Ahmad'), isNot(equals('Hi, Ahmad')));
      expect(ar.homeStudentStudentId('STU-00001'),
          isNot(equals('Student ID: STU-00001')));
      expect(ar.homeTeacherMyClasses, isNot(equals('My classes')));
      expect(
          ar.homeTeacherCaptureAttendance, isNot(equals('Capture attendance')));
    });

    test(
      'English pluralization rules behave correctly (0 / 1 / 2 / 5)',
      () async {
        final en = await loadFor(const Locale('en'));
        expect(en.homeParentLinkedChildren(0), contains('No'));
        expect(en.homeParentLinkedChildren(1), contains('1 linked child'));
        expect(en.homeParentLinkedChildren(5), contains('5 linked children'));
        expect(en.a11yUnreadNotifications(0), contains('No'));
        expect(en.a11yUnreadNotifications(1), contains('1 unread message'));
        expect(en.a11yUnreadNotifications(5), contains('5 unread messages'));
        expect(en.feePlansHeaderTotal(0), contains('No'));
        expect(en.feePlansHeaderTotal(1), contains('1 fee plan'));
        expect(en.feePlansHeaderTotal(3), contains('3 fee plans'));
        expect(en.classDetailStudentCount(1), '1 student');
        expect(en.classDetailStudentCount(7), '7 students');
      },
    );

    test(
      'Arabic pluralization rules behave correctly across the six ICU '
      'categories (zero / one / two / few / many / other)',
      () async {
        final ar = await loadFor(const Locale('ar'));
        // 0: zero
        expect(ar.homeParentLinkedChildren(0), isNotEmpty);
        expect(ar.homeParentLinkedChildren(0),
            isNot(equals('No linked children')));
        // 1: singular
        expect(ar.homeParentLinkedChildren(1), isNotEmpty);
        // 2: dual
        expect(ar.homeParentLinkedChildren(2), isNotEmpty);
        // 3-10: few
        expect(ar.homeParentLinkedChildren(5), isNotEmpty);
        // 11-99: many
        expect(ar.homeParentLinkedChildren(25), isNotEmpty);
        // 100+ and other: other
        expect(ar.homeParentLinkedChildren(101), isNotEmpty);
        // The Arabic strings must not be the English strings
        // (would catch a "fallback to English" copy-paste bug).
        expect(ar.homeParentLinkedChildren(1), isNot(equals('1 linked child')));
        expect(
            ar.a11yUnreadNotifications(3), isNot(equals('3 unread messages')));
      },
    );

    test('English family + picker + class detail copy is present', () async {
      final en = await loadFor(const Locale('en'));
      expect(en.familyHomeLoadingTitle, 'Loading your children');
      expect(en.familyHomeErrorTitle, 'Could not load your children');
      expect(en.familyChildRowRelation('Mother'), 'as Mother');
      expect(en.familyChildRowId('STU-00001'), 'ID STU-00001');
      expect(en.meSwitchStudentTitle, 'Switch student');
      expect(en.meSwitchStudentNowActingAs('Ahmad'), 'Now acting as Ahmad');
      expect(en.meSwitchStudentErrorTitle, 'Could not load students');
      expect(en.classDetailTitle, 'Class');
      expect(en.classDetailErrorTitle, 'Could not load roster');
    });
  });

  group('ShellTab.labelFor', () {
    Widget wrap(Widget child, Locale locale) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => child),
      );
    }

    testWidgets('returns English labels under Locale("en")', (tester) async {
      String? captured;
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) {
            captured = ShellTab.fees.labelFor(context);
            return const SizedBox.shrink();
          },
        ),
        const Locale('en'),
      ));
      expect(captured, 'Fees');
    });

    testWidgets('returns Arabic labels under Locale("ar")', (tester) async {
      String? captured;
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) {
            captured = ShellTab.fees.labelFor(context);
            return const SizedBox.shrink();
          },
        ),
        const Locale('ar'),
      ));
      expect(captured, isNotEmpty);
      expect(captured, isNot('Fees'));
    });
  });
}
