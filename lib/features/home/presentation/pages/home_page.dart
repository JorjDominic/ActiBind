import 'package:actibind/core/settings/family_mode_controller.dart';
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
      _Destination.settings => const SettingsPage(),
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
                        _selected.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (widget.onSignOut != null)
                      IconButton(
                        tooltip: 'Sign out',
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onSignOut,
                        icon: const Icon(Icons.logout_rounded, size: 19),
                      ),
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
