import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/devices/models/registered_device.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisteredDeviceService {
  RegisteredDeviceService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static Future<List<RegisteredDevice>> getDevices() async {
    final response = await _supabase
        .from('registered_devices')
        .select()
        .order('created_at');
    return response.map(RegisteredDevice.fromJson).toList();
  }

  static Future<RegisteredDevice> createDevice({
    required String name,
    required String type,
    required String platform,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in to register a device.');
    }
    final response = await _supabase
        .from('registered_devices')
        .insert({
          'user_id': user.id,
          'name': name.trim(),
          'device_type': type,
          'platform': platform,
        })
        .select()
        .single();
    return RegisteredDevice.fromJson(response);
  }

  static Future<RegisteredDevice> updateDevice({
    required String id,
    required String name,
    required String platform,
  }) async {
    final response = await _supabase
        .from('registered_devices')
        .update({
          'name': name.trim(),
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return RegisteredDevice.fromJson(response);
  }

  static Future<void> deleteDevice(String id) async {
    await _supabase.from('registered_devices').delete().eq('id', id);
  }
}
