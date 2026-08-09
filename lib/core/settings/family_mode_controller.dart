import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyModeController extends ChangeNotifier {
  FamilyModeController._();

  static final FamilyModeController instance = FamilyModeController._();
  static const _preferenceKey = 'family_mode_enabled';

  bool _enabled = false;
  bool get enabled => _enabled;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _enabled = preferences.getBool(_preferenceKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;
    _enabled = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
  }
}
