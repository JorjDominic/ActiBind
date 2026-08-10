import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/activities/models/activity.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ActivityScheduleView extends StatefulWidget {
  const ActivityScheduleView({super.key});

  @override
  State<ActivityScheduleView> createState() => _ActivityScheduleViewState();
}

class _ActivityScheduleViewState extends State<ActivityScheduleView> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  List<Activity> _activities = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _weekStart => _selectedDate.subtract(
    Duration(days: _selectedDate.weekday - DateTime.monday),
  );

  List<Activity> get _selectedActivities => _activities
      .where((item) => DateUtils.isSameDay(item.startsAt, _selectedDate))
      .toList();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ActivityService.getActivities(
        from: _weekStart,
        to: _weekStart.add(const Duration(days: 7)),
      );
      if (!mounted) return;
      setState(() => _activities = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('Supabase has not been initialized')) {
      return 'Activity sync is available after the app starts normally.';
    }
    if (value.contains('activities') && value.contains('schema cache')) {
      return 'The Activity database migration has not been applied yet.';
    }
    return 'Could not sync activities. Check your connection and try again.';
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
      helpText: 'Select activity date',
    );
    if (selected == null || !mounted) return;
    final oldWeek = _weekStart;
    setState(() => _selectedDate = DateUtils.dateOnly(selected));
    if (!DateUtils.isSameDay(oldWeek, _weekStart)) await _load();
  }

  Future<void> _selectDate(DateTime date) async {
    final oldWeek = _weekStart;
    setState(() => _selectedDate = DateUtils.dateOnly(date));
    if (!DateUtils.isSameDay(oldWeek, _weekStart)) await _load();
  }

  Future<void> _create() async {
    final draft = await showModalBottomSheet<ActivityDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ActivityFormSheet(initialDate: _selectedDate),
    );
    if (draft == null || !mounted) return;
    await _mutate(
      () => ActivityService.createActivity(
        name: draft.name,
        category: draft.category,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        repeat: draft.repeat,
        monitorUsage: draft.monitorUsage,
        warnConflicts: draft.warnConflicts,
      ),
    );
  }

  Future<void> _edit(Activity activity) async {
    final draft = await showModalBottomSheet<ActivityDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ActivityFormSheet(activity: activity),
    );
    if (draft == null || !mounted) return;
    await _mutate(
      () => ActivityService.updateActivity(
        id: activity.id,
        name: draft.name,
        category: draft.category,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        repeat: draft.repeat,
        monitorUsage: draft.monitorUsage,
        warnConflicts: draft.warnConflicts,
      ),
    );
  }

  Future<void> _delete(Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text('“${activity.name}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _mutate(() => ActivityService.deleteActivity(activity.id));
    }
  }

  Future<void> _mutate(Future<Object?> Function() operation) async {
    setState(() => _loading = true);
    try {
      await operation();
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.isSameDay(_selectedDate, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today ? 'Today' : DateFormat('EEEE').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat('MMMM d, y').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : _create,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CalendarStrip(
          selectedDate: _selectedDate,
          activities: _activities,
          onSelected: _selectDate,
          onOpenCalendar: _chooseDate,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Scheduled activities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!_loading)
              Text(
                '${_selectedActivities.length}',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 11),
        if (_loading)
          const _LoadingState()
        else if (_error != null)
          _ErrorState(message: _error!, onRetry: _load)
        else if (_selectedActivities.isEmpty)
          _EmptyState(onAdd: _create)
        else
          for (final activity in _selectedActivities) ...[
            _ActivityCard(
              activity: activity,
              onEdit: () => _edit(activity),
              onDelete: () => _delete(activity),
            ),
            const SizedBox(height: 11),
          ],
      ],
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({
    required this.selectedDate,
    required this.activities,
    required this.onSelected,
    required this.onOpenCalendar,
  });

  final DateTime selectedDate;
  final List<Activity> activities;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final start = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final colors = Theme.of(context).colorScheme;
    return shad.Card(
      filled: true,
      fillColor: AppColors.teal.withValues(alpha: .06),
      borderColor: AppColors.teal.withValues(alpha: .2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppColors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('MMMM y').format(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Choose date',
                  onPressed: onOpenCalendar,
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                ),
              ],
            ),
            Row(
              children: List.generate(7, (index) {
                final date = start.add(Duration(days: index));
                final selected = DateUtils.isSameDay(date, selectedDate);
                final hasItems = activities.any(
                  (item) => DateUtils.isSameDay(item.startsAt, date),
                );
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelected(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? colors.onPrimary : null,
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: hasItems
                                    ? (selected
                                          ? colors.onPrimary
                                          : AppColors.coral)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  final Activity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(activity.category);
    final status = _status(activity);
    return shad.Card(
      borderColor: color.withValues(alpha: .24),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(activity.category), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${DateFormat.jm().format(activity.startsAt)} – ${DateFormat.jm().format(activity.endsAt)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _Tag(label: activity.category, color: color),
                      _Tag(label: status, color: _statusColor(status)),
                      if (activity.repeat != 'Never')
                        _Tag(label: activity.repeat, color: AppColors.indigo),
                      if (activity.monitorUsage)
                        const Icon(Icons.shield_outlined, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Activity actions',
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_rounded),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline_rounded),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 36),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => shad.Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 34,
            color: AppColors.teal,
          ),
          const SizedBox(height: 10),
          Text(
            'No activities scheduled',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add an activity for this date to begin planning your day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add activity',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => shad.Card(
    borderColor: AppColors.coral.withValues(alpha: .25),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.coral),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text(
              'Try again',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class ActivityDraft {
  const ActivityDraft({
    required this.name,
    required this.category,
    required this.startsAt,
    required this.endsAt,
    required this.repeat,
    required this.monitorUsage,
    required this.warnConflicts,
  });
  final String name;
  final String category;
  final DateTime startsAt;
  final DateTime endsAt;
  final String repeat;
  final bool monitorUsage;
  final bool warnConflicts;
}

class ActivityFormSheet extends StatefulWidget {
  const ActivityFormSheet({super.key, this.activity, this.initialDate});
  final Activity? activity;
  final DateTime? initialDate;

  @override
  State<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<ActivityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _category;
  late String _repeat;
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late bool _monitor;
  late bool _warnings;

  @override
  void initState() {
    super.initState();
    final item = widget.activity;
    _name = TextEditingController(text: item?.name ?? '');
    _category = item?.category ?? 'Focus';
    _repeat = item?.repeat ?? 'Never';
    _date = DateUtils.dateOnly(
      item?.startsAt ?? widget.initialDate ?? DateTime.now(),
    );
    _start = TimeOfDay.fromDateTime(item?.startsAt ?? DateTime.now());
    _end = TimeOfDay.fromDateTime(
      item?.endsAt ?? DateTime.now().add(const Duration(hours: 1)),
    );
    _monitor = item?.monitorUsage ?? true;
    _warnings = item?.warnConflicts ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  DateTime _combine(TimeOfDay time) =>
      DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime(bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (value != null) setState(() => start ? _start = value : _end = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final startsAt = _combine(_start);
    final endsAt = _combine(_end);
    if (!endsAt.isAfter(startsAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    Navigator.pop(
      context,
      ActivityDraft(
        name: _name.text.trim(),
        category: _category,
        startsAt: startsAt,
        endsAt: endsAt,
        repeat: _repeat,
        monitorUsage: _monitor,
        warnConflicts: _warnings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      16,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.activity == null ? 'Add activity' : 'Edit activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              autofocus: widget.activity == null,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Activity name',
                prefixIcon: Icon(Icons.edit_calendar_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter an activity name'
                  : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items:
                  const [
                        'Study',
                        'Work',
                        'Focus',
                        'Sleep',
                        'Exercise',
                        'Entertainment',
                        'Personal',
                        'Custom',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(DateFormat('EEE, MMM d, y').format(_date)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text('Start  ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text('End  ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _repeat,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: const ['Never', 'Daily', 'Weekdays', 'Weekends']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _repeat = value ?? _repeat),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _monitor,
              onChanged: (value) => setState(() => _monitor = value),
              title: const Text('Monitor device usage'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _warnings,
              onChanged: (value) => setState(() => _warnings = value),
              title: const Text('Warn about conflicts'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(widget.activity == null ? 'Create' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _status(Activity activity) {
  final now = DateTime.now();
  if (now.isBefore(activity.startsAt)) return 'Upcoming';
  if (now.isAfter(activity.endsAt)) return 'Completed';
  return 'Active';
}

Color _statusColor(String status) => switch (status) {
  'Active' => AppColors.teal,
  'Completed' => AppColors.indigo,
  _ => AppColors.amber,
};

Color _categoryColor(String category) => switch (category) {
  'Sleep' => AppColors.indigo,
  'Exercise' => AppColors.coral,
  'Study' || 'Focus' => AppColors.teal,
  'Work' => AppColors.amber,
  _ => AppColors.indigo,
};

IconData _categoryIcon(String category) => switch (category) {
  'Sleep' => Icons.bedtime_rounded,
  'Exercise' => Icons.fitness_center_rounded,
  'Study' => Icons.menu_book_rounded,
  'Work' => Icons.work_rounded,
  'Entertainment' => Icons.sports_esports_rounded,
  _ => Icons.center_focus_strong_rounded,
};
