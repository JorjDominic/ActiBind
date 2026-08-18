import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/developer/services/developer_diagnostics_service.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DeveloperDiagnosticsPage extends StatefulWidget {
  const DeveloperDiagnosticsPage({super.key});

  @override
  State<DeveloperDiagnosticsPage> createState() =>
      _DeveloperDiagnosticsPageState();
}

class _DeveloperDiagnosticsPageState extends State<DeveloperDiagnosticsPage> {
  AiDiagnostics? _ai;
  PackageInfo? _package;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        DeveloperDiagnosticsService.loadAiDiagnostics(),
        PackageInfo.fromPlatform(),
      ]);
      if (!mounted) return;
      setState(() {
        _ai = results[0] as AiDiagnostics;
        _package = results[1] as PackageInfo;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SupabaseService.client.auth.currentSession;
    final user = session?.user;
    final media = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Developer diagnostics')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            const AppPageHeader(
              title: 'System status',
              subtitle: 'Safe runtime and service diagnostics',
            ),
            const SizedBox(height: 18),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              _DiagnosticError(message: _error!, onRetry: _load)
            else if (_ai != null) ...[
              _AiUsageCard(diagnostics: _ai!),
              const SizedBox(height: 12),
            ],
            _DiagnosticSection(
              title: 'AI service',
              children: [
                _DiagnosticRow(label: 'Function', value: 'groq-insights'),
                _DiagnosticRow(
                  label: 'Status',
                  value: _ai == null ? 'Unavailable' : 'Available',
                  valueColor: _ai == null ? AppColors.coral : AppColors.teal,
                ),
                _DiagnosticRow(label: 'Model', value: _ai?.model ?? '—'),
                _DiagnosticRow(
                  label: 'Response time',
                  value: _ai == null ? '—' : '${_ai!.responseTimeMs} ms',
                ),
                _DiagnosticRow(label: 'Edge region', value: _ai?.region ?? '—'),
                _DiagnosticRow(
                  label: 'Deployment',
                  value: _shortValue(_ai?.deploymentId),
                ),
                _DiagnosticRow(
                  label: 'JWT verification',
                  value: _ai?.jwtVerification ?? '—',
                ),
                _DiagnosticRow(
                  label: 'Server checked',
                  value: _ai == null
                      ? '—'
                      : DateFormat.MMMd().add_jms().format(_ai!.serverTime),
                ),
                const _DiagnosticRow(
                  label: 'Budget scope',
                  value: 'Shared app total',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DiagnosticSection(
              title: 'Authentication',
              children: [
                _DiagnosticRow(
                  label: 'Signed in',
                  value: user == null ? 'No' : 'Yes',
                ),
                _DiagnosticRow(
                  label: 'User ID',
                  value: user == null ? '—' : _shortId(user.id),
                ),
                _DiagnosticRow(
                  label: 'Token expires',
                  value: session?.expiresAt == null
                      ? 'Unknown'
                      : DateFormat.yMMMd().add_jm().format(
                          DateTime.fromMillisecondsSinceEpoch(
                            session!.expiresAt! * 1000,
                          ),
                        ),
                ),
                _DiagnosticRow(
                  label: 'Auto refresh',
                  value: session == null ? 'Inactive' : 'Enabled',
                ),
                _DiagnosticRow(
                  label: 'Token remaining',
                  value: session?.expiresAt == null
                      ? 'Unknown'
                      : _formatDuration(
                          DateTime.fromMillisecondsSinceEpoch(
                            session!.expiresAt! * 1000,
                          ).difference(DateTime.now()),
                        ),
                ),
                _DiagnosticRow(
                  label: 'Auth provider',
                  value: user?.appMetadata['provider'] as String? ?? 'Unknown',
                ),
                _DiagnosticRow(
                  label: 'Account created',
                  value: user == null || user.createdAt.isEmpty
                      ? 'Unknown'
                      : _formatTimestamp(user.createdAt),
                ),
                _DiagnosticRow(
                  label: 'Last sign-in',
                  value: user?.lastSignInAt == null
                      ? 'Unknown'
                      : _formatTimestamp(user!.lastSignInAt!),
                ),
                _DiagnosticRow(
                  label: 'Anonymous account',
                  value: user?.isAnonymous == true ? 'Yes' : 'No',
                ),
                _DiagnosticRow(
                  label: 'MFA factors',
                  value: '${user?.factors?.length ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DiagnosticSection(
              title: 'Application',
              children: [
                _DiagnosticRow(
                  label: 'Version',
                  value: _package == null
                      ? 'Unknown'
                      : '${_package!.version} (${_package!.buildNumber})',
                ),
                _DiagnosticRow(label: 'Platform', value: _platformName),
                _DiagnosticRow(
                  label: 'Build mode',
                  value: kReleaseMode
                      ? 'Release'
                      : kProfileMode
                      ? 'Profile'
                      : 'Debug',
                ),
                _DiagnosticRow(
                  label: 'Local time zone',
                  value: DateTime.now().timeZoneName,
                ),
                _DiagnosticRow(
                  label: 'Locale',
                  value: Localizations.localeOf(context).toLanguageTag(),
                ),
                _DiagnosticRow(
                  label: 'Logical display',
                  value:
                      '${media.size.width.round()} × ${media.size.height.round()}',
                ),
                _DiagnosticRow(
                  label: 'Pixel ratio',
                  value: media.devicePixelRatio.toStringAsFixed(2),
                ),
                _DiagnosticRow(
                  label: 'Text scale',
                  value: media.textScaler.scale(1).toStringAsFixed(2),
                ),
                _DiagnosticRow(
                  label: 'Orientation',
                  value: media.orientation.name,
                ),
                _DiagnosticRow(
                  label: 'Activity cache revision',
                  value: '${ActivityService.cacheRevision}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Secrets, access tokens, email addresses, and API keys are intentionally hidden.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortId(String id) => id.length <= 13
      ? id
      : '${id.substring(0, 8)}…${id.substring(id.length - 4)}';

  static String _shortValue(String? value) {
    if (value == null || value == 'Unknown') return 'Unknown';
    return value.length <= 16 ? value : '${value.substring(0, 16)}…';
  }

  static String _formatTimestamp(String value) {
    final timestamp = DateTime.tryParse(value)?.toLocal();
    return timestamp == null
        ? 'Unknown'
        : DateFormat.yMMMd().add_jm().format(timestamp);
  }

  static String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Expired';
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
  }

  String get _platformName {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }
}

class _AiUsageCard extends StatelessWidget {
  const _AiUsageCard({required this.diagnostics});
  final AiDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) => shad.Card(
    filled: true,
    fillColor: AppColors.indigo.withValues(alpha: .06),
    borderColor: AppColors.indigo.withValues(alpha: .22),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.data_usage_rounded, color: AppColors.indigo),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Daily AI token budget',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(diagnostics.usageFraction * 100).clamp(0, 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: diagnostics.usageFraction.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 10),
          Text(
            '${NumberFormat.decimalPattern().format(diagnostics.tokensUsed)} used · '
            '${NumberFormat.decimalPattern().format(diagnostics.tokensRemaining)} remaining',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Limit ${NumberFormat.decimalPattern().format(diagnostics.dailyLimit)} · '
            'Resets ${DateFormat.MMMd().add_jm().format(diagnostics.resetAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DiagnosticSection extends StatelessWidget {
  const _DiagnosticSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => shad.Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Divider(height: 22),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  );
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
        ),
      ),
    ],
  );
}

class _DiagnosticError extends StatelessWidget {
  const _DiagnosticError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: ListTile(
      leading: const Icon(Icons.error_outline_rounded, color: AppColors.coral),
      title: const Text('Could not load live diagnostics'),
      subtitle: Text(message),
      trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
    ),
  );
}
