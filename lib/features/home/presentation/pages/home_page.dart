import 'package:actibind/features/home/presentation/pages/activity_ledger_page.dart';
import 'package:actibind/features/home/presentation/pages/child_restriction_page.dart';
import 'package:actibind/features/home/presentation/pages/home_overview_page.dart';
import 'package:actibind/features/home/presentation/pages/settings_page.dart';
import 'package:actibind/features/home/presentation/pages/screen_time_dashboard_page.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeOverviewPage(),
    ActivityLedgerPage(),
    ScreenTimeDashboardPage(),
    ChildRestrictionPage(),
    SettingsPage(),
  ];

  static const List<String> _titles = <String>[
    'Home',
    'Activity',
    'Insights',
    'Family',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigation = _AppNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _onItemTapped,
        );

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
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.indigo, AppColors.teal],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.track_changes,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _titles[_selectedIndex],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const shad.Divider(),
          ],
          footers: [
            const shad.Divider(),
            SafeArea(top: false, child: navigation),
          ],
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppNavigation extends StatelessWidget {
  const _AppNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    ('Home', Icons.home_rounded),
    ('Activity', Icons.view_timeline_rounded),
    ('Insights', Icons.insights_rounded),
    ('Family', Icons.family_restroom_rounded),
    ('Settings', Icons.settings_rounded),
  ];

  static const _colors = [
    AppColors.indigo,
    AppColors.teal,
    AppColors.amber,
    AppColors.coral,
    Color(0xFF667085),
  ];

  @override
  Widget build(BuildContext context) {
    return shad.NavigationBar(
      direction: Axis.horizontal,
      expanded: true,
      expandedSize: 48,
      alignment: shad.NavigationBarAlignment.spaceAround,
      labelType: shad.NavigationLabelType.none,
      selectedKey: ValueKey(selectedIndex),
      onSelected: (key) => onSelected((key as ValueKey<int>).value),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        for (var index = 0; index < _items.length; index++)
          shad.NavigationItem(
            key: ValueKey(index),
            label: Text(_items[index].$1),
            selectedStyle: const shad.ButtonStyle.ghost(
              density: shad.ButtonDensity.icon,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? _colors[index].withValues(alpha: .14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _items[index].$2,
                size: 20,
                color: selectedIndex == index
                    ? _colors[index]
                    : AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }
}
