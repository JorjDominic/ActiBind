import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/todos/services/todo_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const _channel = MethodChannel('com.example.actibind/home_widgets');

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> refreshAll() async {
    if (!_supported) return;
    await Future.wait([refreshTodos(), refreshNextActivity()]);
  }

  static Future<void> refreshTodos() async {
    if (!_supported) return;
    try {
      final todos = (await TodoService.getTodos())
          .where((todo) => !todo.completed)
          .toList();
      final visible = todos
          .take(4)
          .map((todo) {
            final due = todo.dueDate == null
                ? ''
                : ' · ${DateFormat.MMMd().format(todo.dueDate!)}';
            return '${_priorityMarker(todo.priority)} ${todo.title}$due';
          })
          .join('\n');
      await _update({
        'todo_count': todos.length,
        'todo_items': visible.isEmpty ? 'No open tasks' : visible,
      });
    } catch (_) {
      // Keep the last successful widget state while offline.
    }
  }

  static Future<void> refreshNextActivity() async {
    if (!_supported) return;
    try {
      final now = DateTime.now();
      final activities = await ActivityService.getActivities(
        from: now.subtract(const Duration(minutes: 1)),
        to: now.add(const Duration(days: 7)),
      );
      final upcoming = activities
          .where((activity) => activity.endsAt.isAfter(now))
          .firstOrNull;
      await _update({
        'activity_name': upcoming?.name ?? 'Nothing scheduled',
        'activity_time': upcoming == null
            ? 'Your next 7 days are open'
            : '${DateFormat.MMMd().format(upcoming.startsAt)} · '
                  '${DateFormat.jm().format(upcoming.startsAt)}–'
                  '${DateFormat.jm().format(upcoming.endsAt)}',
        'activity_category': upcoming?.category ?? 'Planner',
      });
    } catch (_) {
      // Keep the last successful widget state while offline.
    }
  }

  static Future<void> updateInsight(String insight) async {
    if (!_supported || insight.trim().isEmpty) return;
    await _update({
      'insight': insight.trim(),
      'insight_updated': 'Updated ${DateFormat.jm().format(DateTime.now())}',
    });
  }

  static Future<void> _update(Map<String, Object> values) async {
    try {
      await _channel.invokeMethod<void>('updateWidgets', values);
    } on PlatformException {
      // Widgets remain optional and must never interrupt the main app.
    }
  }

  static String _priorityMarker(String priority) => switch (priority) {
    'high' => '●',
    'low' => '○',
    _ => '◉',
  };
}
