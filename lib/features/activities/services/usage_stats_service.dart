import 'dart:io';

import 'package:actibind/features/activities/models/app_usage.dart';
import 'package:flutter/services.dart';

class UsageStatsService {
  UsageStatsService._();

  static const _channel = MethodChannel('com.example.actibind/usage_stats');
  static final _cache = <String, _UsageCacheEntry>{};
  static final _inFlight = <String, Future<List<AppUsage>>>{};
  static const _cacheLifetime = Duration(seconds: 30);

  static bool get isSupported => Platform.isAndroid;

  static Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('hasPermission') ?? false;
  }

  static Future<void> openPermissionSettings() async {
    if (isSupported) await _channel.invokeMethod<void>('openSettings');
  }

  static Future<List<AppUsage>> getUsage({
    required DateTime start,
    required DateTime end,
    bool forceRefresh = false,
  }) async {
    if (!isSupported) return const [];
    final key =
        '${start.millisecondsSinceEpoch ~/ 60000}:'
        '${end.millisecondsSinceEpoch ~/ 60000}';
    final cached = _cache[key];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.loadedAt) < _cacheLifetime) {
      return cached.items;
    }
    if (!forceRefresh && _inFlight[key] != null) return _inFlight[key]!;

    final request = _loadUsage(start: start, end: end);
    _inFlight[key] = request;
    try {
      final items = await request;
      _cache[key] = _UsageCacheEntry(items: items, loadedAt: DateTime.now());
      if (_cache.length > 4) _cache.remove(_cache.keys.first);
      return items;
    } finally {
      _inFlight.remove(key);
    }
  }

  static Future<List<AppUsage>> _loadUsage({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _channel.invokeListMethod<Object?>('getUsageStats', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return (rows ?? const [])
        .cast<Map<Object?, Object?>>()
        .map(AppUsage.fromMap)
        .toList(growable: false);
  }

  static void clearCache() => _cache.clear();
}

class _UsageCacheEntry {
  const _UsageCacheEntry({required this.items, required this.loadedAt});
  final List<AppUsage> items;
  final DateTime loadedAt;
}
