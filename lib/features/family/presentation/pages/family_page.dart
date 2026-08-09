import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/family/models/family_models.dart';
import 'package:actibind/features/family/presentation/pages/child_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage child profiles, devices, and screen time',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const _ActiveBadge(),
            ],
          ),
          const SizedBox(height: 20),
          const _FamilySummary(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Child profiles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                '${mockChildren.length} profiles',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = mockChildren
                  .map((child) => _ChildCard(child: child))
                  .toList();
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.75,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _showAddChildSheet(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add / Link Child'),
          ),
          const SizedBox(height: 24),
          shad.Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Same-Device Child Mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Temporarily restrict this device before giving it to a child.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => _showChildModeSheet(context),
                          icon: const Icon(Icons.lock_clock_rounded),
                          label: const Text('Start Child Mode'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddChildSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddChildSheet(),
    );
  }

  void _showChildModeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ChildModeSheet(),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.teal.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 15, color: AppColors.teal),
        SizedBox(width: 5),
        Text(
          'Active',
          style: TextStyle(
            color: AppColors.teal,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _FamilySummary extends StatelessWidget {
  const _FamilySummary();
  @override
  Widget build(BuildContext context) {
    const items = [
      ('2', 'Children', Icons.people_alt_rounded, AppColors.indigo),
      ('2', 'Linked devices', Icons.devices_rounded, AppColors.teal),
      ('3', 'Restrictions', Icons.shield_rounded, AppColors.coral),
      ('Off', 'Child mode', Icons.phone_android_rounded, AppColors.amber),
    ];
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 10,
            runSpacing: 16,
            children: [
              for (final item in items)
                SizedBox(
                  width: constraints.maxWidth < 520
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - 30) / 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.$3, color: item.$4, size: 20),
                      const SizedBox(height: 7),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});
  final ChildProfile child;
  @override
  Widget build(BuildContext context) => shad.Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ChildProfilePage(child: child))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: child.color.withValues(alpha: .15),
              child: Text(
                child.initials,
                style: TextStyle(
                  color: child.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          child.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Text(
                        'Child',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        child.connected
                            ? Icons.cloud_done_rounded
                            : Icons.person_rounded,
                        size: 14,
                        color: child.connected
                            ? AppColors.teal
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          child.device,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Today: ${child.screenTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        child.restrictionsActive
                            ? 'Restrictions active'
                            : 'No restrictions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: child.restrictionsActive
                              ? AppColors.coral
                              : AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _AddChildSheet extends StatefulWidget {
  const _AddChildSheet();
  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  int mode = 0;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Add or link a child',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.person_add_rounded),
                label: Text('Create Profile'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.link_rounded),
                label: Text('Link Device'),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (value) => setState(() => mode = value.first),
          ),
          const SizedBox(height: 20),
          if (mode == 0) ...[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Child name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: '9–12',
              decoration: const InputDecoration(
                labelText: 'Age range',
                border: OutlineInputBorder(),
              ),
              items: const ['Under 6', '6–8', '9–12', '13–15', '16–17']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save Profile'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.indigo.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    'YOUR LINKING CODE',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '482 917',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Share this code with the child device',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter a linking code',
                prefixIcon: Icon(Icons.password_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Link Device'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _ChildModeSheet extends StatefulWidget {
  const _ChildModeSheet();
  @override
  State<_ChildModeSheet> createState() => _ChildModeSheetState();
}

class _ChildModeSheetState extends State<_ChildModeSheet> {
  String child = 'Alex';
  String duration = '1 hour';
  bool useExistingRestrictions = true;
  bool ready = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          ready ? 'Child Mode Ready' : 'Set up Child Mode',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        if (!ready) ...[
          DropdownButtonFormField<String>(
            initialValue: child,
            decoration: const InputDecoration(
              labelText: 'Child profile',
              border: OutlineInputBorder(),
            ),
            items: mockChildren
                .map(
                  (profile) => DropdownMenuItem(
                    value: profile.name,
                    child: Text(profile.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => child = value ?? child),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: duration,
            decoration: const InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(),
            ),
            items: const ['30 minutes', '1 hour', '2 hours', 'Custom']
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => duration = value ?? duration),
          ),
          const SizedBox(height: 14),
          RadioGroup<bool>(
            groupValue: useExistingRestrictions,
            onChanged: (value) {
              if (value != null) {
                setState(() => useExistingRestrictions = value);
              }
            },
            child: const Column(
              children: [
                RadioListTile(
                  value: true,
                  title: Text('Use child’s existing restrictions'),
                ),
                RadioListTile(
                  value: false,
                  title: Text('Create temporary restrictions'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => setState(() => ready = true),
            child: const Text('Review Child Mode'),
          ),
        ] else ...[
          _ReviewRow(label: 'Child', value: child),
          _ReviewRow(label: 'Duration', value: duration),
          const _ReviewRow(label: 'Allowed apps', value: '5'),
          const _ReviewRow(label: 'Restricted apps', value: '8'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.lock_rounded),
            label: const Text('Start Child Mode'),
          ),
        ],
      ],
    ),
  );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
