class ActivityValidation {
  ActivityValidation._();

  static const categories = <String>{
    'Study',
    'Work',
    'Focus',
    'Sleep',
    'Exercise',
    'Entertainment',
    'Personal',
    'Custom',
  };

  static const repeatOptions = <String>{
    'Never',
    'Daily',
    'Weekdays',
    'Weekends',
  };

  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String? nameError(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter an activity name';
    if (name.length > 100) {
      return 'Activity name must be 100 characters or less';
    }
    if (name.contains(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'))) {
      return 'Activity name contains unsupported characters';
    }
    return null;
  }

  static void validateId(String id) {
    if (!_uuid.hasMatch(id)) {
      throw const FormatException('Invalid activity identifier.');
    }
  }

  static void validateRange({required DateTime from, required DateTime to}) {
    if (!to.isAfter(from)) {
      throw const FormatException(
        'The end of the date range must be after its start.',
      );
    }
    if (to.difference(from) > const Duration(days: 366)) {
      throw const FormatException(
        'Activity date ranges cannot exceed one year.',
      );
    }
  }

  static bool intervalsOverlap({
    required DateTime firstStart,
    required DateTime firstEnd,
    required DateTime secondStart,
    required DateTime secondEnd,
  }) => firstStart.isBefore(secondEnd) && firstEnd.isAfter(secondStart);

  static void validateActivity({
    required String name,
    required String category,
    required DateTime startsAt,
    required DateTime endsAt,
    required String repeat,
    bool requireFutureStart = false,
    DateTime? now,
  }) {
    final error = nameError(name);
    if (error != null) throw FormatException(error);
    if (!categories.contains(category)) {
      throw const FormatException('Select a valid activity category.');
    }
    if (!repeatOptions.contains(repeat)) {
      throw const FormatException('Select a valid repeat option.');
    }
    if (!endsAt.isAfter(startsAt)) {
      throw const FormatException('End time must be after start time.');
    }
    final current = now ?? DateTime.now();
    final currentMinute = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute,
    );
    if (requireFutureStart && startsAt.isBefore(currentMinute)) {
      throw const FormatException(
        'Start date and time cannot be earlier than the current time.',
      );
    }
  }
}
