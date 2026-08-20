import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildModeSession {
  const ChildModeSession({
    required this.childName,
    required this.endsAt,
    required this.allowedPackages,
    required this.restrictedCount,
  });

  final String childName;
  final DateTime endsAt;
  final List<String> allowedPackages;
  final int restrictedCount;

  int get remainingMinutes {
    final value = endsAt.difference(DateTime.now()).inMinutes;
    return value < 1 ? 1 : value;
  }
}

class ChildModeSessionService {
  ChildModeSessionService._();

  static const _active = 'child_mode_session_active';
  static const _child = 'child_mode_session_child';
  static const _endsAt = 'child_mode_session_ends_at';
  static const _allowed = 'child_mode_session_allowed';
  static const _restrictedCount = 'child_mode_session_restricted_count';
  static const _pinSalt = 'child_mode_parent_pin_salt';
  static const _pinHash = 'child_mode_parent_pin_hash';

  static Future<void> save({
    required String childName,
    required int minutes,
    required Set<String> allowedPackages,
    required int restrictedCount,
    required String pin,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final salt = List<int>.generate(24, (_) => Random.secure().nextInt(256));
    await preferences.setBool(_active, true);
    await preferences.setString(_child, childName);
    await preferences.setString(
      _endsAt,
      DateTime.now().add(Duration(minutes: minutes)).toIso8601String(),
    );
    await preferences.setStringList(_allowed, allowedPackages.toList());
    await preferences.setInt(_restrictedCount, restrictedCount);
    await preferences.setString(_pinSalt, base64Encode(salt));
    await preferences.setString(_pinHash, _hash(pin, salt));
  }

  static Future<ChildModeSession?> load() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_active) != true) return null;
    final endsAt = DateTime.tryParse(preferences.getString(_endsAt) ?? '');
    if (endsAt == null || !endsAt.isAfter(DateTime.now())) {
      await clear();
      return null;
    }
    return ChildModeSession(
      childName: preferences.getString(_child) ?? 'Child',
      endsAt: endsAt,
      allowedPackages: preferences.getStringList(_allowed) ?? const [],
      restrictedCount: preferences.getInt(_restrictedCount) ?? 0,
    );
  }

  static Future<bool> verifyPin(String pin) async {
    final preferences = await SharedPreferences.getInstance();
    final saltValue = preferences.getString(_pinSalt);
    final expected = preferences.getString(_pinHash);
    if (saltValue == null || expected == null) return false;
    return _hash(pin, base64Decode(saltValue)) == expected;
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      _active,
      _child,
      _endsAt,
      _allowed,
      _restrictedCount,
      _pinSalt,
      _pinHash,
    ]) {
      await preferences.remove(key);
    }
  }

  static String _hash(String pin, List<int> salt) =>
      sha256.convert([...salt, ...utf8.encode(pin)]).toString();
}
