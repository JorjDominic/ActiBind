import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/features/home/presentation/pages/activity_ledger_page.dart';
import 'package:actibind/features/home/presentation/pages/child_restriction_page.dart';
import 'package:actibind/features/home/presentation/pages/home_overview_page.dart';
import 'package:actibind/features/home/presentation/pages/pattern_insight_page.dart';
import 'package:actibind/features/home/presentation/pages/settings_page.dart';
import 'package:actibind/features/home/presentation/pages/screen_time_dashboard_page.dart';
import 'package:actibind/features/home/presentation/pages/smart_warning_page.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';

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
    SmartWarningPage(),
    ScreenTimeDashboardPage(),
    PatternInsightPage(),
    ChildRestrictionPage(),
    SettingsPage(),
  ];

  static const List<String> _titles = <String>[
    'Home',
    'Activity Ledger',
    'Smart Warning Tool',
    'Screen Time Dashboard',
    'Pattern Insight Locator',
    'Child Restriction',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(
          _titles[_selectedIndex],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      childPad: false,
      child: _pages[_selectedIndex],
      footer: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: _onItemTapped,
        safeAreaBottom: true,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: Text('Ledger'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: Text('Warnings'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: Text('Screen'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: Text('Patterns'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: Text('Child'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios, size: 18, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
