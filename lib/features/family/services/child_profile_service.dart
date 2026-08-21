import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/family/models/family_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildProfileService {
  ChildProfileService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static Future<List<ChildProfile>> getProfiles() async {
    final response = await _supabase
        .from('child_profiles')
        .select()
        .order('created_at');
    return response.map(ChildProfile.fromJson).toList();
  }

  static Future<ChildProfile> createProfile({
    required String name,
    required String ageRange,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in before creating a child profile.');
    }
    final response = await _supabase
        .from('child_profiles')
        .insert({
          'user_id': user.id,
          'name': name.trim(),
          'age_range': ageRange,
        })
        .select()
        .single();
    return ChildProfile.fromJson(response);
  }

  static Future<ChildProfile> updateProfile({
    required String id,
    required String name,
    required String ageRange,
    required String device,
    required bool connected,
    required bool restrictionsActive,
  }) async {
    final response = await _supabase
        .from('child_profiles')
        .update({
          'name': name.trim(),
          'age_range': ageRange,
          'device_name': device.trim().isEmpty
              ? 'No device linked'
              : device.trim(),
          'connected': connected,
          'restrictions_active': restrictionsActive,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return ChildProfile.fromJson(response);
  }

  static Future<void> deleteProfile(String id) async {
    await _supabase.from('child_profiles').delete().eq('id', id);
  }

  static Future<void> addScreenTime(String id, int minutes) async {
    if (minutes <= 0) return;
    final current = await _supabase
        .from('child_profiles')
        .select('screen_time_minutes')
        .eq('id', id)
        .single();
    final total = (current['screen_time_minutes'] as int? ?? 0) + minutes;
    await _supabase
        .from('child_profiles')
        .update({
          'screen_time_minutes': total,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }
}
