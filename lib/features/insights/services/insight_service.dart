import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/activities/services/usage_stats_service.dart';

class InsightChatMessage {
  const InsightChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class InsightService {
  InsightService._();

  static Future<String> generateHomeInsight() => _request(
    prompt:
        'Give me one concise, practical insight for today in no more than two sentences.',
    mode: 'home',
  );

  static Future<String> generateDailyInsight() => _request(
    prompt:
        'Analyze my recent activity and give me a useful daily insight with one specific next action.',
    mode: 'daily',
  );

  static Future<String> ask({
    required String question,
    List<InsightChatMessage> history = const [],
  }) => _request(prompt: question, mode: 'chat', history: history);

  static Future<String> _request({
    required String prompt,
    required String mode,
    List<InsightChatMessage> history = const [],
  }) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      throw const FormatException(
        'Enter a question for the insights assistant.',
      );
    }
    if (cleanPrompt.length > 1000) {
      throw const FormatException(
        'Questions must be 1,000 characters or less.',
      );
    }

    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    final to = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final activities = await ActivityService.getActivities(from: from, to: to);

    var usage = const <Map<String, Object>>[];
    if (UsageStatsService.isSupported) {
      try {
        if (await UsageStatsService.hasPermission()) {
          final rows = await UsageStatsService.getUsage(
            start: DateTime(now.year, now.month, now.day),
            end: now,
          );
          usage = rows
              .take(10)
              .map<Map<String, Object>>(
                (item) => {
                  'app': item.appName,
                  'foreground_minutes': item.foreground.inMinutes,
                },
              )
              .toList(growable: false);
        }
      } catch (_) {
        // Schedule-based insights remain available without native usage data.
      }
    }

    final response = await SupabaseService.client.functions.invoke(
      'groq-insights',
      body: {
        'mode': mode,
        'prompt': cleanPrompt,
        'activities': activities
            .map(
              (item) => {
                'name': item.name,
                'category': item.category,
                'starts_at': item.startsAt.toIso8601String(),
                'ends_at': item.endsAt.toIso8601String(),
                'repeat': item.repeat,
              },
            )
            .toList(growable: false),
        'usage': usage,
        'history': history
            .where(
              (item) =>
                  (item.role == 'user' || item.role == 'assistant') &&
                  item.content.trim().isNotEmpty,
            )
            .take(8)
            .map((item) => item.toJson())
            .toList(growable: false),
        'timezone': now.timeZoneName,
        'local_time': now.toIso8601String(),
      },
    );

    if (response.status != 200 || response.data is! Map) {
      throw Exception('The insights service is temporarily unavailable.');
    }
    final data = Map<String, dynamic>.from(response.data as Map);
    final insight = data['insight'] as String?;
    if (insight == null || insight.trim().isEmpty) {
      throw Exception('The insights service returned an empty response.');
    }
    return insight.trim();
  }
}
