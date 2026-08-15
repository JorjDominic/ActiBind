import 'package:actibind/features/activities/services/activity_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityValidation', () {
    test('accepts a valid activity', () {
      final start = DateTime(2026, 8, 15, 10);
      expect(
        () => ActivityValidation.validateActivity(
          name: 'Deep work',
          category: 'Focus',
          startsAt: start,
          endsAt: start.add(const Duration(hours: 1)),
          repeat: 'Weekdays',
        ),
        returnsNormally,
      );
    });

    test('rejects invalid names and option values', () {
      final start = DateTime(2026, 8, 15, 10);
      expect(
        () => ActivityValidation.validateActivity(
          name: '   ',
          category: 'Unknown',
          startsAt: start,
          endsAt: start.add(const Duration(hours: 1)),
          repeat: 'Sometimes',
        ),
        throwsFormatException,
      );
      expect(ActivityValidation.nameError('x' * 101), isNotNull);
    });

    test('rejects reversed times and completed new activities', () {
      final now = DateTime(2026, 8, 15, 12);
      expect(
        () => ActivityValidation.validateActivity(
          name: 'Old task',
          category: 'Work',
          startsAt: now.subtract(const Duration(hours: 2)),
          endsAt: now.subtract(const Duration(hours: 1)),
          repeat: 'Never',
          requireFutureStart: true,
          now: now,
        ),
        throwsFormatException,
      );
      expect(
        () => ActivityValidation.validateActivity(
          name: 'Bad range',
          category: 'Work',
          startsAt: now,
          endsAt: now,
          repeat: 'Never',
        ),
        throwsFormatException,
      );
    });

    test('validates query ranges and record identifiers', () {
      final from = DateTime(2026, 1, 1);
      expect(
        () => ActivityValidation.validateRange(from: from, to: from),
        throwsFormatException,
      );
      expect(
        () => ActivityValidation.validateRange(
          from: from,
          to: from.add(const Duration(days: 367)),
        ),
        throwsFormatException,
      );
      expect(
        () => ActivityValidation.validateId('not-an-id'),
        throwsFormatException,
      );
      expect(
        () => ActivityValidation.validateId(
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        returnsNormally,
      );
    });
  });
}
