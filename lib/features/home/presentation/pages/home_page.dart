import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/features/home/presentation/pages/activity_ledger_page.dart';
import 'package:actibind/features/home/presentation/pages/child_restriction_page.dart';
import 'package:actibind/features/home/presentation/pages/home_overview_page.dart';
import 'package:actibind/features/home/presentation/pages/pattern_insight_page.dart';
import 'package:actibind/features/home/presentation/pages/screen_time_dashboard_page.dart';
import 'package:actibind/features/home/presentation/pages/smart_warning_page.dart';
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
  ];

  static const List<String> _titles = <String>[
    'Home',
    'Activity Ledger',
    'Smart Warning Tool',
    'Screen Time Dashboard',
    'Pattern Insight Locator',
    'Child Restriction',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Ledger',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Warnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Patterns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Child',
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
