import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/family/models/family_models.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({super.key, required this.child});
  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: child.color.withValues(alpha: .15),
                child: Text(
                  child.initials,
                  style: TextStyle(
                    color: child.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      child.device,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                child.connected
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                size: 19,
                color: child.connected ? AppColors.teal : AppColors.muted,
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Screen Time'),
              Tab(text: 'Schedule'),
              Tab(text: 'Restrictions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(child: child),
            _ScreenTimeTab(child: child),
            const _ScheduleTab(),
            const _RestrictionsTab(),
          ],
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.child});
  final ChildProfile child;
  @override
  Widget build(BuildContext context) => _TabBody(
    children: [
      shad.Card(
        filled: true,
        fillColor: AppColors.indigo.withValues(alpha: .08),
        borderColor: AppColors.indigo.withValues(alpha: .16),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily screen time',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                child.screenTime,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of 3h daily limit',
                style: TextStyle(color: AppColors.muted),
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: (child.screenTimeMinutes / 180).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _MiniStat(
            icon: Icons.schedule_rounded,
            title: 'Schedule',
            value: 'Study Block Active',
            color: AppColors.teal,
          ),
          _MiniStat(
            icon: Icons.shield_rounded,
            title: 'Restrictions',
            value: '3 Apps Restricted',
            color: AppColors.coral,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      const _AppUsageTile(
        icon: Icons.play_circle_outline_rounded,
        name: 'YouTube',
        usage: '35 min',
        progress: .58,
        color: Color(0xFFE05252),
      ),
      const _AppUsageTile(
        icon: Icons.music_note_rounded,
        name: 'TikTok',
        usage: '22 min',
        progress: .37,
        color: AppColors.ink,
      ),
      const _AppUsageTile(
        icon: Icons.language_rounded,
        name: 'Chrome',
        usage: '18 min',
        progress: .30,
        color: Color(0xFF4285F4),
      ),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ScreenTimeTab extends StatefulWidget {
  const _ScreenTimeTab({required this.child});
  final ChildProfile child;
  @override
  State<_ScreenTimeTab> createState() => _ScreenTimeTabState();
}

class _ScreenTimeTabState extends State<_ScreenTimeTab> {
  int range = 0;
  @override
  Widget build(BuildContext context) => _TabBody(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Today')),
            ButtonSegment(value: 1, label: Text('Week')),
          ],
          selected: {range},
          showSelectedIcon: false,
          onSelectionChanged: (value) => setState(() => range = value.first),
        ),
      ),
      const SizedBox(height: 16),
      shad.Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total screen time',
                style: TextStyle(color: AppColors.muted),
              ),
              SizedBox(height: 5),
              Text(
                widget.child.screenTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${(180 - widget.child.screenTimeMinutes).clamp(0, 180)} minutes remaining',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15),
              LinearProgressIndicator(
                value: (widget.child.screenTimeMinutes / 180).clamp(0, 1),
                minHeight: 9,
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      Text('Most-used apps', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      const _AppUsageTile(
        icon: Icons.play_circle_outline_rounded,
        name: 'YouTube',
        usage: '35m',
        progress: .70,
        color: Color(0xFFE05252),
      ),
      const _AppUsageTile(
        icon: Icons.music_note_rounded,
        name: 'TikTok',
        usage: '22m',
        progress: .44,
        color: AppColors.coral,
      ),
      const _AppUsageTile(
        icon: Icons.language_rounded,
        name: 'Chrome',
        usage: '18m',
        progress: .36,
        color: Color(0xFF4285F4),
      ),
      const _AppUsageTile(
        icon: Icons.sports_esports_rounded,
        name: 'Games',
        usage: '14m',
        progress: .28,
        color: AppColors.indigo,
      ),
    ],
  );
}

class _AppUsageTile extends StatelessWidget {
  const _AppUsageTile({
    required this.icon,
    required this.name,
    required this.usage,
    required this.progress,
    required this.color,
  });
  final IconData icon;
  final String name;
  final String usage;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(usage),
                ],
              ),
              const SizedBox(height: 7),
              LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                color: color,
                backgroundColor: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();
  @override
  Widget build(BuildContext context) => _TabBody(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Weekly schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showAddSchedule(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const _ScheduleCard(
        icon: Icons.menu_book_rounded,
        name: 'Study',
        time: '7:00 PM – 9:00 PM',
        days: 'Mon–Fri',
        status: 'Restrictions active',
        color: AppColors.indigo,
      ),
      const SizedBox(height: 12),
      const _ScheduleCard(
        icon: Icons.bedtime_rounded,
        name: 'Sleep',
        time: '10:00 PM – 6:00 AM',
        days: 'Every day',
        status: 'Device locked',
        color: AppColors.coral,
      ),
      const SizedBox(height: 12),
      const _ScheduleCard(
        icon: Icons.celebration_rounded,
        name: 'Free Time',
        time: '4:00 PM – 6:00 PM',
        days: 'Weekends',
        status: 'Standard limits',
        color: AppColors.teal,
      ),
    ],
  );

  void _showAddSchedule(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add schedule', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Activity name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Starts',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Ends',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.icon,
    required this.name,
    required this.time,
    required this.days,
    required this.status,
    required this.color,
  });
  final IconData icon;
  final String name;
  final String time;
  final String days;
  final String status;
  final Color color;
  @override
  Widget build(BuildContext context) => shad.Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  days,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded),
        ],
      ),
    ),
  );
}

class _RestrictionsTab extends StatefulWidget {
  const _RestrictionsTab();
  @override
  State<_RestrictionsTab> createState() => _RestrictionsTabState();
}

class _RestrictionsTabState extends State<_RestrictionsTab> {
  double hours = 3;
  String behavior = 'Restrict App';
  final statuses = <String, String>{
    'TikTok': 'Restricted',
    'YouTube': 'Limited',
    'Chrome': 'Allowed',
    'Games': 'Restricted',
  };

  @override
  Widget build(BuildContext context) => _TabBody(
    children: [
      _Section(
        title: 'Screen Time Limit',
        icon: Icons.timer_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Daily screen time')),
                Text(
                  '${hours.toInt()} hours',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Slider(
              value: hours,
              min: 1,
              max: 8,
              divisions: 14,
              label: '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)}h',
              onChanged: (value) => setState(() => hours = value),
            ),
            const Wrap(
              spacing: 7,
              children: [
                Chip(label: Text('Mon–Fri')),
                Chip(label: Text('Weekends')),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _Section(
        title: 'App Restrictions',
        icon: Icons.apps_rounded,
        child: Column(
          children: [
            for (final entry in statuses.entries)
              _RestrictionApp(
                name: entry.key,
                status: entry.value,
                onChanged: (value) =>
                    setState(() => statuses[entry.key] = value!),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const _Section(
        title: 'Schedule-Based Restrictions',
        icon: Icons.event_busy_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Study Mode', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('7:00 PM – 9:00 PM', style: TextStyle(color: AppColors.muted)),
            SizedBox(height: 12),
            Text(
              'Restricted',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.coral,
              ),
            ),
            SizedBox(height: 5),
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text('TikTok')),
                Chip(label: Text('Games')),
                Chip(label: Text('Instagram')),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Allowed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
            SizedBox(height: 5),
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text('Chrome')),
                Chip(label: Text('Classroom')),
                Chip(label: Text('Calculator')),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _Section(
        title: 'When Limit Is Reached',
        icon: Icons.warning_amber_rounded,
        child: RadioGroup<String>(
          groupValue: behavior,
          onChanged: (value) {
            if (value != null) {
              setState(() => behavior = value);
            }
          },
          child: Column(
            children: [
              for (final option in [
                'Send Reminder',
                'Strong Warning',
                'Restrict App',
              ])
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: option,
                  title: Text(option),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      shad.Card(
        filled: true,
        fillColor: AppColors.indigo.withValues(alpha: .08),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.indigo),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Restriction settings are protected by your Parent PIN.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => shad.Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.indigo),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    ),
  );
}

class _RestrictionApp extends StatelessWidget {
  const _RestrictionApp({
    required this.name,
    required this.status,
    required this.onChanged,
  });
  final String name;
  final String status;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.indigo.withValues(alpha: .1),
          child: const Icon(
            Icons.apps_rounded,
            size: 17,
            color: AppColors.indigo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'Usage today: 22m',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: status,
          underline: const SizedBox(),
          items: const ['Allowed', 'Limited', 'Restricted']
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
