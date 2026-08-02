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
//     state messages).
//   * The shell's `ShellTab.labelFor(context)` resolves the
//     right label per locale.
//
// The test surface is intentionally narrow: the home screens
// still carry ~150 hardcoded English strings that are the
// "future hardening pass" follow-up. The `ShellTab` labels
// are localized because the bottom nav is the single most
// visible piece of UI in the app.

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
  });

  group('ShellTab.labelFor', () {
    Widget _wrap(Widget child, Locale locale) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => child),
      );
    }

    testWidgets('returns English labels under Locale("en")', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(
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
      await tester.pumpWidget(_wrap(
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
