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

  static Future<List<Activity>> getConflictingActivities({
    required DateTime startsAt,
    required DateTime endsAt,
    String? excludingId,
  }) async {
    if (!endsAt.isAfter(startsAt)) {
      throw const FormatException('End time must be after start time.');
    }
    if (excludingId != null) ActivityValidation.validateId(excludingId);

    var query = _supabase
        .from('activities')
        .select()
        .lt('starts_at', endsAt.toUtc().toIso8601String())
        .gt('ends_at', startsAt.toUtc().toIso8601String());
    if (excludingId != null) query = query.neq('id', excludingId);
    final response = await query.order('starts_at');
    return response.map(Activity.fromJson).toList();
  }

  static Future<int> getConflictingActivityCount({
    required DateTime from,
    required DateTime to,
  }) async {
    final conflicts = await getConflictingActivitiesInRange(from: from, to: to);
    return conflicts.length;
  }

  static Future<List<Activity>> getConflictingActivitiesInRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final activities = await getActivities(from: from, to: to);
    final conflictingIds = <String>{};
    for (var first = 0; first < activities.length; first++) {
      for (var second = first + 1; second < activities.length; second++) {
        final a = activities[first];
        final b = activities[second];
        if (ActivityValidation.intervalsOverlap(
          firstStart: a.startsAt,
          firstEnd: a.endsAt,
          secondStart: b.startsAt,
          secondEnd: b.endsAt,
        )) {
          conflictingIds
            ..add(a.id)
            ..add(b.id);
        }
      }
    }
    return activities
        .where((activity) => conflictingIds.contains(activity.id))
        .toList();
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
