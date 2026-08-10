import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/features/home/presentation/pages/activity_ledger_page.dart';
import 'package:actibind/features/family/presentation/pages/family_page.dart';
import 'package:actibind/features/home/presentation/pages/home_overview_page.dart';
import 'package:actibind/features/home/presentation/pages/settings_page.dart';
import 'package:actibind/features/home/presentation/pages/screen_time_dashboard_page.dart';
import 'package:actibind/shared/widgets/actibind_logo.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.displayName = 'there', this.onSignOut});

  final String displayName;
  final Future<void> Function()? onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _Destination _selected = _Destination.home;

  @override
  void initState() {
    super.initState();
    FamilyModeController.instance.addListener(_handleFamilyModeChange);
  }

  @override
  void dispose() {
    FamilyModeController.instance.removeListener(_handleFamilyModeChange);
    super.dispose();
  }

  void _handleFamilyModeChange() {
    if (!FamilyModeController.instance.enabled &&
        _selected == _Destination.family) {
      _selected = _Destination.home;
    }
    if (mounted) setState(() {});
  }

  void _onItemTapped(_Destination destination) {
    setState(() => _selected = destination);
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_selected) {
      _Destination.home => HomeOverviewPage(displayName: widget.displayName),
      _Destination.activity => const ActivityLedgerPage(),
      _Destination.insights => const ScreenTimeDashboardPage(),
      _Destination.family => const FamilyPage(),
      _Destination.settings => SettingsPage(onSignOut: widget.onSignOut),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return shad.Scaffold(
          headers: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    const ActibindLogo(size: 30, borderRadius: 8),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const _NotificationsButton(),
                  ],
                ),
              ),
            ),
            const shad.Divider(),
          ],
          footers: [
            const shad.Divider(),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 10),
              child: AnimatedBuilder(
                animation: FamilyModeController.instance,
                builder: (context, _) => _AppNavigation(
                  selected: _selected,
                  familyModeEnabled: FamilyModeController.instance.enabled,
                  onSelected: _onItemTapped,
                ),
              ),
            ),
          ],
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(key: ValueKey(_selected), child: page),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      visualDensity: VisualDensity.compact,
      onPressed: () => _showNotifications(context),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 20),
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _NotificationTile(
              icon: Icons.warning_amber_rounded,
              color: AppColors.amber,
              title: 'Focus conflict detected',
              detail: 'TikTok was active during your Study block.',
              time: '12 min ago',
            ),
            const Divider(height: 1),
            const _NotificationTile(
              icon: Icons.insights_rounded,
              color: AppColors.teal,
              title: 'Weekly insight ready',
              detail: 'Your focused time improved by 15% this week.',
              time: '2h ago',
            ),
            const Divider(height: 1),
            const _NotificationTile(
              icon: Icons.schedule_rounded,
              color: AppColors.indigo,
              title: 'Project Work starts soon',
              detail: 'Your next scheduled block begins at 3:00 PM.',
              time: 'Today',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AppNavigation extends StatelessWidget {
  const _AppNavigation({
    required this.selected,
    required this.familyModeEnabled,
    required this.onSelected,
  });

  final _Destination selected;
  final bool familyModeEnabled;
  final ValueChanged<_Destination> onSelected;

  List<_Destination> get _items => [
    _Destination.home,
    _Destination.activity,
    _Destination.insights,
    if (familyModeEnabled) _Destination.family,
    _Destination.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return shad.NavigationBar(
      key: ValueKey(familyModeEnabled),
      direction: Axis.horizontal,
      expanded: true,
      expandedSize: 48,
      alignment: shad.NavigationBarAlignment.spaceAround,
      labelType: shad.NavigationLabelType.none,
      selectedKey: ValueKey(selected),
      onSelected: (key) => onSelected((key as ValueKey<_Destination>).value),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        for (final item in _items)
          shad.NavigationItem(
            key: ValueKey(item),
            label: Text(item.title),
            selectedStyle: const shad.ButtonStyle.ghost(
              density: shad.ButtonDensity.icon,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected == item
                    ? item.color.withValues(alpha: .14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: selected == item ? item.color : AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }
}

enum _Destination {
  home('Home', Icons.home_rounded, AppColors.indigo),
  activity('Activity', Icons.view_timeline_rounded, AppColors.teal),
  insights('Insights', Icons.insights_rounded, AppColors.amber),
  family('Family', Icons.family_restroom_rounded, AppColors.coral),
  settings('Settings', Icons.settings_rounded, Color(0xFF667085));

  const _Destination(this.title, this.icon, this.color);

  final String title;
  final IconData icon;
  final Color color;
}
