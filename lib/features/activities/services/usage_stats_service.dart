import 'dart:io';

import 'package:actibind/features/activities/models/app_usage.dart';
import 'package:flutter/services.dart';

class UsageStatsService {
  UsageStatsService._();

  static const _channel = MethodChannel('com.example.actibind/usage_stats');

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
  }) async {
    if (!isSupported) return const [];
    final rows = await _channel.invokeListMethod<Object?>('getUsageStats', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return (rows ?? const [])
        .cast<Map<Object?, Object?>>()
        .map(AppUsage.fromMap)
        .toList(growable: false);
  }
}
