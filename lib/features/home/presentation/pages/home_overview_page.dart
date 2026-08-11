import 'dart:typed_data';

import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/activities/models/app_usage.dart';
import 'package:actibind/features/activities/services/usage_stats_service.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({
    super.key,
    required this.displayName,
    required this.onStartFocus,
    required this.onImproveWindDown,
    required this.onPlanWorkout,
    required this.onPlanPersonal,
  });

  final String displayName;
  final VoidCallback onStartFocus;
  final VoidCallback onImproveWindDown;
  final VoidCallback onPlanWorkout;
  final VoidCallback onPlanPersonal;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'GOOD MORNING';
    if (hour >= 12 && hour < 17) return 'GOOD AFTERNOON';
    if (hour >= 17 && hour < 22) return 'GOOD EVENING';
    return 'GOOD NIGHT';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Overview',
            subtitle: 'Your focus, routines, and next actions at a glance',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.indigo, Color(0xFF7779EA), AppColors.teal],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: .22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Make today count, $displayName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      const Text(
                        'You’ve completed 72% of your focus goal.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: .72,
                          strokeWidth: 9,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Text(
                        '72%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  title: 'Focus today',
                  value: '4h 20m',
                  subtitle: 'of 6h goal',
                  color: AppColors.indigo,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  title: 'Distractions',
                  value: '2',
                  subtitle: 'down 3 this week',
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const AppSectionHeader(
            title: 'Quick Actions',
            subtitle: 'Keep your day moving',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, _) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 76,
              children: [
                _ActionCard(
                  icon: Icons.lock_clock,
                  title: 'Focus time',
                  color: AppColors.indigo,
                  onTap: onStartFocus,
                ),
                _ActionCard(
                  icon: Icons.nightlight_round,
                  title: 'Wind-down',
                  color: AppColors.teal,
                  onTap: onImproveWindDown,
                ),
                _ActionCard(
                  icon: Icons.fitness_center_rounded,
                  title: 'Workout',
                  color: AppColors.coral,
                  onTap: onPlanWorkout,
                ),
                _ActionCard(
                  icon: Icons.checklist_rounded,
                  title: 'Personal task',
                  color: AppColors.amber,
                  onTap: onPlanPersonal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _TopActivity(),
          const SizedBox(height: 24),
          const AppSectionHeader(
            title: 'Your latest insight',
            subtitle: 'A pattern worth knowing from your recent activity',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.teal.withValues(alpha: .13),
                  AppColors.indigo.withValues(alpha: .09),
                ],
              ),
              border: Border.all(color: AppColors.teal.withValues(alpha: .18)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppColors.teal),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Your best focus window is 9:00–11:30 AM. Protect that time for your most important work.',
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActivity extends StatefulWidget {
  const _TopActivity();

  @override
  State<_TopActivity> createState() => _TopActivityState();
}

class _TopActivityState extends State<_TopActivity>
    with WidgetsBindingObserver {
  List<AppUsage> _usage = const [];
  bool _loading = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!UsageStatsService.isSupported) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final allowed = await UsageStatsService.hasPermission();
      var items = const <AppUsage>[];
      if (allowed) {
        final now = DateTime.now();
        items = await UsageStatsService.getUsage(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      }
      if (mounted) {
        setState(() {
          _allowed = allowed;
          _usage = items.take(3).toList(growable: false);
        });
      }
    } catch (_) {
      // Keep the overview usable if native usage data is temporarily unavailable.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(
        title: 'Top Activity',
        subtitle: 'Your three most-used apps today',
      ),
      const SizedBox(height: 12),
      if (_loading)
        const LinearProgressIndicator()
      else if (!_allowed)
        Text(
          UsageStatsService.isSupported
              ? 'Allow usage access in Activity to see your top apps.'
              : 'Top activity is available on Android.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        )
      else if (_usage.isEmpty)
        const Text('No app activity recorded today.')
      else
        shad.Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (var index = 0; index < _usage.length; index++) ...[
                  _TopActivityRow(rank: index + 1, usage: _usage[index]),
                  if (index != _usage.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
    ],
  );
}

class _TopActivityRow extends StatelessWidget {
  const _TopActivityRow({required this.rank, required this.usage});

  final int rank;
  final AppUsage usage;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        _HomeAppIcon(bytes: usage.iconBytes),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            usage.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Text(_duration(usage.foreground)),
      ],
    ),
  );

  static String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
  }
}

class _HomeAppIcon extends StatelessWidget {
  const _HomeAppIcon({required this.bytes});
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AppColors.indigo.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(9),
    ),
    child: bytes == null
        ? const Icon(Icons.apps_rounded, size: 20, color: AppColors.indigo)
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.apps_rounded,
                size: 20,
                color: AppColors.indigo,
              ),
            ),
          ),
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      filled: true,
      fillColor: color.withValues(alpha: .07),
      borderColor: color.withValues(alpha: .16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .035),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: .22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
