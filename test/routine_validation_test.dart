import 'package:actibind/features/routines/services/routine_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoutineValidation', () {
    test('accepts a valid everyday routine', () {
      expect(
        () => RoutineValidation.validate(
          name: 'Morning focus',
          category: 'Focus',
          startMinutes: 8 * 60,
          endMinutes: 9 * 60,
          activeDays: {1, 2, 3, 4, 5, 6, 7},
          startsOn: DateTime(2026, 8, 16),
        ),
        returnsNormally,
      );
    });

    test('rejects empty days, reversed times, and reversed dates', () {
      expect(
        () => RoutineValidation.validate(
          name: 'Bad routine',
          category: 'Focus',
          startMinutes: 10 * 60,
          endMinutes: 9 * 60,
          activeDays: const {},
          startsOn: DateTime(2026, 8, 17),
          endsOn: DateTime(2026, 8, 16),
        ),
        throwsFormatException,
      );
    });

    test('detects overlaps only on shared days', () {
      expect(
        RoutineValidation.overlaps(
          firstStart: 8 * 60,
          firstEnd: 10 * 60,
          firstDays: const {1, 3},
          secondStart: 9 * 60,
          secondEnd: 11 * 60,
          secondDays: const {3, 5},
        ),
        isTrue,
      );
      expect(
        RoutineValidation.overlaps(
          firstStart: 8 * 60,
          firstEnd: 10 * 60,
          firstDays: const {1},
          secondStart: 9 * 60,
          secondEnd: 11 * 60,
          secondDays: const {2},
        ),
        isFalse,
      );
    });
  });
}
