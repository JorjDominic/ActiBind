import 'package:actibind/features/activities/models/activity.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/activities/services/usage_stats_service.dart';
import 'package:actibind/features/insights/models/insight_metrics.dart';
import 'package:intl/intl.dart';

class InsightMetricsService {
  InsightMetricsService._();

  static const dailyFocusGoal = Duration(hours: 6);
  static const _focusCategories = {'Focus', 'Study', 'Work'};
  static final _cache = <String, _MetricsCacheEntry>{};
  static final _inFlight = <String, Future<InsightMetrics>>{};
  static const _cacheLifetime = Duration(seconds: 30);

  static Future<InsightMetrics> load({required int days}) async {
    final key = '$days:${ActivityService.cacheRevision}';
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.loadedAt) < _cacheLifetime) {
      return cached.metrics;
    }
    if (_inFlight[key] != null) return _inFlight[key]!;
    final request = _compute(days: days);
    _inFlight[key] = request;
    try {
      final metrics = await request;
      _cache[key] = _MetricsCacheEntry(
        metrics: metrics,
        loadedAt: DateTime.now(),
      );
      if (_cache.length > 4) _cache.remove(_cache.keys.first);
      return metrics;
    } finally {
      _inFlight.remove(key);
    }
  }

  static Future<InsightMetrics> _compute({required int days}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(Duration(days: days - 1));
    final activities = await ActivityService.getActivities(
      from: from,
      to: today.add(const Duration(days: 1)),
    );

    var usingUsage = false;
    var todayValue = _elapsedDuration(
      activities.where((item) => _isToday(item.startsAt, today)),
      now,
    );
    if (UsageStatsService.isSupported) {
      try {
        if (await UsageStatsService.hasPermission()) {
          final usage = await UsageStatsService.getUsage(
            start: today,
            end: now,
          );
          todayValue = usage.fold(
            Duration.zero,
            (total, item) => total + item.foreground,
          );
          usingUsage = true;
        }
      } catch (_) {
        // Scheduled activity remains a useful fallback.
      }
    }

    final elapsedTotal = _elapsedDuration(activities, now);
    final elapsedDays = now.difference(from).inDays + 1;
    final focusToday = _elapsedDuration(
      activities.where(
        (item) =>
            _isToday(item.startsAt, today) &&
            _focusCategories.contains(item.category),
      ),
      now,
    );

    final weekdayMinutes = List<int>.filled(7, 0);
    final hourlyFocusMinutes = List<int>.filled(24, 0);
    for (final activity in activities) {
      final duration = _effectiveDuration(activity, now);
      weekdayMinutes[activity.startsAt.weekday - 1] += duration.inMinutes;
      if (_focusCategories.contains(activity.category)) {
        hourlyFocusMinutes[activity.startsAt.hour] += duration.inMinutes;
      }
    }
    final maxDay = weekdayMinutes.fold<int>(0, (a, b) => a > b ? a : b);
    final levels = weekdayMinutes
        .map((value) => maxDay == 0 ? 0.08 : (value / maxDay).clamp(.08, 1.0))
        .toList(growable: false);
    final peakMinutes = hourlyFocusMinutes.fold<int>(
      0,
      (a, b) => a > b ? a : b,
    );
    var peakWindow = 'Not enough focus activity yet';
    if (peakMinutes > 0) {
      final peakHour = hourlyFocusMinutes.indexOf(peakMinutes);
      final start = DateTime(2026, 1, 1, peakHour);
      peakWindow =
          '${DateFormat.jm().format(start)}–${DateFormat.jm().format(start.add(const Duration(hours: 1)))}';
    }

    return InsightMetrics(
      todayValue: todayValue,
      todayLabel: usingUsage ? 'device usage today' : 'elapsed schedule today',
      dailyAverage: Duration(
        milliseconds: elapsedTotal.inMilliseconds ~/ elapsedDays,
      ),
      goalProgress: (focusToday.inMinutes / dailyFocusGoal.inMinutes).clamp(
        0,
        1,
      ),
      dayLevels: levels,
      dayDurations: weekdayMinutes
          .map((minutes) => Duration(minutes: minutes))
          .toList(growable: false),
      peakWindow: peakWindow,
    );
  }

  static Duration _elapsedDuration(
    Iterable<Activity> activities,
    DateTime now,
  ) => activities.fold(
    Duration.zero,
    (total, item) => total + _effectiveDuration(item, now),
  );

  static Duration _effectiveDuration(Activity activity, DateTime now) {
    if (!activity.startsAt.isBefore(now)) return Duration.zero;
    final end = activity.endsAt.isBefore(now) ? activity.endsAt : now;
    return end.isAfter(activity.startsAt)
        ? end.difference(activity.startsAt)
        : Duration.zero;
  }

  static bool _isToday(DateTime value, DateTime today) =>
      value.year == today.year &&
      value.month == today.month &&
      value.day == today.day;

  static String formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _MetricsCacheEntry {
  const _MetricsCacheEntry({required this.metrics, required this.loadedAt});
  final InsightMetrics metrics;
  final DateTime loadedAt;
}
