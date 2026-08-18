import 'package:actibind/features/todos/services/todo_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoValidation', () {
    test('accepts valid task data', () {
      expect(
        () => TodoValidation.validate(
          title: 'Prepare presentation',
          priority: 'high',
          notes: 'Review the final slides.',
        ),
        returnsNormally,
      );
    });

    test('rejects invalid titles, priorities, and long notes', () {
      expect(TodoValidation.titleError('  '), isNotNull);
      expect(
        TodoValidation.titleError(List.filled(121, 'x').join()),
        isNotNull,
      );
      expect(
        () => TodoValidation.validate(title: 'Task', priority: 'urgent'),
        throwsFormatException,
      );
      expect(
        () => TodoValidation.validate(
          title: 'Task',
          priority: 'low',
          notes: List.filled(1001, 'x').join(),
        ),
        throwsFormatException,
      );
    });
  });
}
