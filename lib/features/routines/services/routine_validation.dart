import 'package:actibind/features/activities/services/activity_validation.dart';

class RoutineValidation {
  RoutineValidation._();

  static void validate({
    required String name,
    required String category,
    required int startMinutes,
    required int endMinutes,
    required Set<int> activeDays,
    required DateTime startsOn,
    DateTime? endsOn,
  }) {
    final nameError = ActivityValidation.nameError(name);
    if (nameError != null) throw FormatException(nameError);
    if (!ActivityValidation.categories.contains(category)) {
      throw const FormatException('Select a valid routine category.');
    }
    if (startMinutes < 0 ||
        startMinutes >= 1440 ||
        endMinutes < 0 ||
        endMinutes >= 1440) {
      throw const FormatException('Select valid start and end times.');
    }
    if (endMinutes <= startMinutes) {
      throw const FormatException('End time must be after start time.');
    }
    if (activeDays.isEmpty || activeDays.any((day) => day < 1 || day > 7)) {
      throw const FormatException('Select at least one active day.');
    }
    final start = DateTime(startsOn.year, startsOn.month, startsOn.day);
    if (endsOn != null) {
      final end = DateTime(endsOn.year, endsOn.month, endsOn.day);
      if (end.isBefore(start)) {
        throw const FormatException('End date cannot be before start date.');
      }
    }
  }

  static bool overlaps({
    required int firstStart,
    required int firstEnd,
    required Set<int> firstDays,
    required int secondStart,
    required int secondEnd,
    required Set<int> secondDays,
  }) =>
      firstDays.intersection(secondDays).isNotEmpty &&
      firstStart < secondEnd &&
      firstEnd > secondStart;
}
