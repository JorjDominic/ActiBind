class TodoValidation {
  TodoValidation._();

  static const priorities = {'low', 'medium', 'high'};

  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String? titleError(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Enter a task title';
    if (title.length > 120) return 'Task title must be 120 characters or less';
    if (title.contains(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'))) {
      return 'Task title contains unsupported characters';
    }
    return null;
  }

  static void validate({
    required String title,
    required String priority,
    String? notes,
  }) {
    final error = titleError(title);
    if (error != null) throw FormatException(error);
    if (!priorities.contains(priority)) {
      throw const FormatException('Select a valid priority.');
    }
    if ((notes?.trim().length ?? 0) > 1000) {
      throw const FormatException('Notes must be 1000 characters or less.');
    }
  }

  static void validateId(String id) {
    if (!_uuid.hasMatch(id)) {
      throw const FormatException('Invalid task identifier.');
    }
  }
}
