import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailySummaryController extends ChangeNotifier {
  DailySummaryController._();

  static final instance = DailySummaryController._();
  static const _preferenceKey = 'daily_summary_enabled';

  bool _enabled = true;
  bool get enabled => _enabled;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _enabled = preferences.getBool(_preferenceKey) ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;
    _enabled = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
  }
}
