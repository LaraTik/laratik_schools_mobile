// SPDX-License-Identifier: Proprietary
// Derive the available grade + class-group filter values from a
// loaded student list.
//
// The v1 SDK does not expose a "list grades" / "list class groups"
// endpoint today, so the Students screen derives its filter
// options from the rows the mobile has already pulled. The
// previous hard-coded `['Grade 1', 'Grade 2', ...]` and
// `['A', 'B', 'C', 'D']` lists lied to the operator when the
// school uses a different catalog (e.g. "Year 1" or "KG-2"). The
// derived list is honest: it shows the grades + class groups that
// exist in the data the mobile has already pulled.
//
// Backend follow-up: add `get_school_grades` and
// `get_school_class_groups` so the mobile can pre-populate the
// filter chips without waiting for a student list to be loaded.

import 'person.dart';

/// A derived set of grade + class-group options extracted from a
/// loaded [PersonPage]. Sorted case-insensitively for stable
/// display order across locale changes.
class DerivedFilterOptions {
  const DerivedFilterOptions({
    required this.grades,
    required this.classGroups,
  });

  /// De-duplicated grade values from the loaded students, in
  /// case-insensitive sort order. Empty when no rows are loaded
  /// (so the filter chip can render in a disabled state).
  final List<String> grades;

  /// De-duplicated class-group values from the loaded students, in
  /// case-insensitive sort order. Empty when no rows are loaded.
  final List<String> classGroups;

  bool get isEmpty => grades.isEmpty && classGroups.isEmpty;
}

/// Compute the available filter values from the loaded
/// [PersonPage]. Pure function; safe to call from anywhere
/// (including tests, see
/// `test/features/people/filter_options_test.dart`).
DerivedFilterOptions deriveFilterOptions(Iterable<Person> people) {
  final grades = <String>{
    for (final p in people)
      if ((p.grade ?? '').isNotEmpty) p.grade!,
  }.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  final classGroups = <String>{
    for (final p in people)
      if ((p.classGroup ?? '').isNotEmpty) p.classGroup!,
  }.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return DerivedFilterOptions(grades: grades, classGroups: classGroups);
}
