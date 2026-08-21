import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/routines/models/routine.dart';
import 'package:actibind/features/routines/services/routine_validation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineService {
  RoutineService._();

  static SupabaseClient get _supabase => SupabaseService.client;
  static List<Routine>? _cache;
  static DateTime? _loadedAt;

  static Future<List<Routine>> getRoutines({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache != null &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < const Duration(seconds: 30)) {
      return _cache!;
    }
    final response = await _supabase
        .from('routines')
        .select()
        .order('start_time');
    final routines = response.map(Routine.fromJson).toList(growable: false);
    _cache = routines;
    _loadedAt = DateTime.now();
    return routines;
  }

  static Future<Map<String, RoutineOccurrence>> getOccurrences(
    DateTime date,
  ) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final response = await _supabase
        .from('routine_occurrences')
        .select()
        .eq('scheduled_date', key);
    return {
      for (final row in response)
        row['routine_id'] as String: RoutineOccurrence.fromJson(row),
    };
  }

  static Future<Routine> createRoutine({
    required String name,
    required String category,
    required int startMinutes,
    required int endMinutes,
    required Set<int> activeDays,
    required DateTime startsOn,
    DateTime? endsOn,
    required bool monitorUsage,
    required bool warnConflicts,
    int reminderMinutes = 5,
  }) async {
    RoutineValidation.validate(
      name: name,
      category: category,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      activeDays: activeDays,
      startsOn: startsOn,
      endsOn: endsOn,
    );
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in before creating a routine.');
    }
    final response = await _supabase
        .from('routines')
        .insert({
          'user_id': user.id,
          'name': name.trim(),
          'category': category,
          'start_time': _time(startMinutes),
          'end_time': _time(endMinutes),
          'active_days': activeDays.toList()..sort(),
          'starts_on': DateFormat('yyyy-MM-dd').format(startsOn),
          'ends_on': endsOn == null
              ? null
              : DateFormat('yyyy-MM-dd').format(endsOn),
          'monitor_usage': monitorUsage,
          'warn_conflicts': warnConflicts,
          'reminder_minutes': reminderMinutes,
        })
        .select()
        .single();
    clearCache();
    return Routine.fromJson(response);
  }

  static Future<Routine> updateRoutine({
    required String id,
    required String name,
    required String category,
    required int startMinutes,
    required int endMinutes,
    required Set<int> activeDays,
    required DateTime startsOn,
    DateTime? endsOn,
    required bool active,
    required bool monitorUsage,
    required bool warnConflicts,
    int reminderMinutes = 5,
  }) async {
    RoutineValidation.validate(
      name: name,
      category: category,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      activeDays: activeDays,
      startsOn: startsOn,
      endsOn: endsOn,
    );
    final response = await _supabase
        .from('routines')
        .update({
          'name': name.trim(),
          'category': category,
          'start_time': _time(startMinutes),
          'end_time': _time(endMinutes),
          'active_days': activeDays.toList()..sort(),
          'starts_on': DateFormat('yyyy-MM-dd').format(startsOn),
          'ends_on': endsOn == null
              ? null
              : DateFormat('yyyy-MM-dd').format(endsOn),
          'active': active,
          'monitor_usage': monitorUsage,
          'warn_conflicts': warnConflicts,
          'reminder_minutes': reminderMinutes,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    clearCache();
    return Routine.fromJson(response);
  }

  static Future<void> setActive(Routine routine, bool active) => updateRoutine(
    id: routine.id,
    name: routine.name,
    category: routine.category,
    startMinutes: routine.startMinutes,
    endMinutes: routine.endMinutes,
    activeDays: routine.activeDays,
    startsOn: routine.startsOn,
    endsOn: routine.endsOn,
    active: active,
    monitorUsage: routine.monitorUsage,
    warnConflicts: routine.warnConflicts,
    reminderMinutes: routine.reminderMinutes,
  );

  static Future<void> setOccurrenceStatus({
    required String routineId,
    required DateTime date,
    required String status,
  }) async {
    if (!{'scheduled', 'completed', 'skipped'}.contains(status)) {
      throw const FormatException('Invalid routine status.');
    }
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Sign in to update a routine.');
    await _supabase.from('routine_occurrences').upsert({
      'routine_id': routineId,
      'user_id': user.id,
      'scheduled_date': DateFormat('yyyy-MM-dd').format(date),
      'status': status,
      'completed_at': status == 'completed'
          ? DateTime.now().toUtc().toIso8601String()
          : null,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'routine_id,scheduled_date');
  }

  static Future<void> deleteRoutine(String id) async {
    await _supabase.from('routines').delete().eq('id', id);
    clearCache();
  }

  static String _time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}:00';

  static void clearCache() {
    _cache = null;
    _loadedAt = null;
  }
}
