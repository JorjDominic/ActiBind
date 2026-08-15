import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/activities/models/activity.dart';
import 'package:actibind/features/activities/services/activity_validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityService {
  ActivityService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static Future<List<Activity>> getActivities({
    required DateTime from,
    required DateTime to,
  }) async {
    ActivityValidation.validateRange(from: from, to: to);
    final response = await _supabase
        .from('activities')
        .select()
        .gte('starts_at', from.toUtc().toIso8601String())
        .lt('starts_at', to.toUtc().toIso8601String())
        .order('starts_at');
    return response.map(Activity.fromJson).toList();
  }

  static Future<Activity> createActivity({
    required String name,
    required String category,
    required DateTime startsAt,
    required DateTime endsAt,
    required String repeat,
    required bool monitorUsage,
    required bool warnConflicts,
  }) async {
    ActivityValidation.validateActivity(
      name: name,
      category: category,
      startsAt: startsAt,
      endsAt: endsAt,
      repeat: repeat,
      requireFutureStart: true,
    );
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in before creating an activity.');
    }
    final response = await _supabase
        .from('activities')
        .insert({
          'user_id': user.id,
          'name': name.trim(),
          'category': category,
          'starts_at': startsAt.toUtc().toIso8601String(),
          'ends_at': endsAt.toUtc().toIso8601String(),
          'repeat': repeat,
          'monitor_usage': monitorUsage,
          'warn_conflicts': warnConflicts,
        })
        .select()
        .single();
    return Activity.fromJson(response);
  }

  static Future<Activity> updateActivity({
    required String id,
    required String name,
    required String category,
    required DateTime startsAt,
    required DateTime endsAt,
    required String repeat,
    required bool monitorUsage,
    required bool warnConflicts,
  }) async {
    ActivityValidation.validateId(id);
    ActivityValidation.validateActivity(
      name: name,
      category: category,
      startsAt: startsAt,
      endsAt: endsAt,
      repeat: repeat,
    );
    final response = await _supabase
        .from('activities')
        .update({
          'name': name.trim(),
          'category': category,
          'starts_at': startsAt.toUtc().toIso8601String(),
          'ends_at': endsAt.toUtc().toIso8601String(),
          'repeat': repeat,
          'monitor_usage': monitorUsage,
          'warn_conflicts': warnConflicts,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return Activity.fromJson(response);
  }

  static Future<void> deleteActivity(String id) async {
    ActivityValidation.validateId(id);
    await _supabase.from('activities').delete().eq('id', id);
  }
}
