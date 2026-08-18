import 'package:actibind/core/services/supabase_service.dart';

class AiDiagnostics {
  const AiDiagnostics({
    required this.model,
    required this.dailyLimit,
    required this.tokensUsed,
    required this.resetAt,
    required this.serverTime,
    required this.responseTimeMs,
    required this.region,
    required this.deploymentId,
    required this.jwtVerification,
  });

  final String model;
  final int dailyLimit;
  final int tokensUsed;
  final DateTime resetAt;
  final DateTime serverTime;
  final int responseTimeMs;
  final String region;
  final String deploymentId;
  final String jwtVerification;
  int get tokensRemaining => (dailyLimit - tokensUsed).clamp(0, dailyLimit);
  double get usageFraction => dailyLimit == 0 ? 0 : tokensUsed / dailyLimit;

  factory AiDiagnostics.fromJson(
    Map<String, dynamic> json, {
    required int responseTimeMs,
  }) => AiDiagnostics(
    model: json['model'] as String? ?? 'Unknown',
    dailyLimit: (json['daily_token_limit'] as num?)?.toInt() ?? 0,
    tokensUsed: (json['tokens_used_today'] as num?)?.toInt() ?? 0,
    resetAt: DateTime.parse(json['resets_at'] as String).toLocal(),
    serverTime: DateTime.parse(json['server_time'] as String).toLocal(),
    responseTimeMs: responseTimeMs,
    region: json['region'] as String? ?? 'Unknown',
    deploymentId: json['deployment_id'] as String? ?? 'Unknown',
    jwtVerification: json['jwt_verification'] as String? ?? 'Unknown',
  );
}

class DeveloperDiagnosticsService {
  DeveloperDiagnosticsService._();

  static Future<AiDiagnostics> loadAiDiagnostics() async {
    final timer = Stopwatch()..start();
    final response = await SupabaseService.client.functions.invoke(
      'groq-insights',
      body: const {'mode': 'diagnostics'},
    );
    if (response.data is! Map) {
      throw const FormatException('Invalid diagnostics response.');
    }
    timer.stop();
    return AiDiagnostics.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      responseTimeMs: timer.elapsedMilliseconds,
    );
  }
}
