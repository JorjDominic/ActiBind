import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/todos/models/todo_item.dart';
import 'package:actibind/features/todos/services/todo_validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoService {
  TodoService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static Future<List<TodoItem>> getTodos() async {
    final response = await _supabase
        .from('todos')
        .select()
        .order('completed')
        .order('due_date', nullsFirst: false)
        .order('created_at', ascending: false);
    return response.map(TodoItem.fromJson).toList();
  }

  static Future<TodoItem> createTodo({
    required String title,
    required String priority,
    String? notes,
    DateTime? dueDate,
  }) async {
    TodoValidation.validate(title: title, priority: priority, notes: notes);
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in before creating a task.');
    }
    final response = await _supabase
        .from('todos')
        .insert({
          'user_id': user.id,
          'title': title.trim(),
          'notes': _nullableText(notes),
          'priority': priority,
          'due_date': dueDate == null ? null : _dateValue(dueDate),
        })
        .select()
        .single();
    return TodoItem.fromJson(response);
  }

  static Future<TodoItem> updateTodo({
    required String id,
    required String title,
    required String priority,
    String? notes,
    DateTime? dueDate,
  }) async {
    TodoValidation.validateId(id);
    TodoValidation.validate(title: title, priority: priority, notes: notes);
    final response = await _supabase
        .from('todos')
        .update({
          'title': title.trim(),
          'notes': _nullableText(notes),
          'priority': priority,
          'due_date': dueDate == null ? null : _dateValue(dueDate),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return TodoItem.fromJson(response);
  }

  static Future<TodoItem> setCompleted(TodoItem todo, bool completed) async {
    TodoValidation.validateId(todo.id);
    final now = DateTime.now().toUtc().toIso8601String();
    final response = await _supabase
        .from('todos')
        .update({
          'completed': completed,
          'completed_at': completed ? now : null,
          'updated_at': now,
        })
        .eq('id', todo.id)
        .select()
        .single();
    return TodoItem.fromJson(response);
  }

  static Future<void> deleteTodo(String id) async {
    TodoValidation.validateId(id);
    await _supabase.from('todos').delete().eq('id', id);
  }

  static String? _nullableText(String? value) {
    final cleaned = value?.trim() ?? '';
    return cleaned.isEmpty ? null : cleaned;
  }

  static String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
