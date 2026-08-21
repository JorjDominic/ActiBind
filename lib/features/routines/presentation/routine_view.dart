import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/core/services/notification_service.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/activities/services/activity_validation.dart';
import 'package:actibind/features/routines/models/routine.dart';
import 'package:actibind/features/routines/services/routine_service.dart';
import 'package:actibind/features/routines/services/routine_validation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class RoutineView extends StatefulWidget {
  const RoutineView({super.key});

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  List<Routine> _routines = const [];
  Map<String, RoutineOccurrence> _occurrences = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RoutineService.getRoutines(forceRefresh: refresh),
        RoutineService.getOccurrences(DateTime.now()),
      ]);
      if (!mounted) return;
      setState(() {
        _routines = results[0] as List<Routine>;
        _occurrences = results[1] as Map<String, RoutineOccurrence>;
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              'Could not sync routines. Check your connection and migration.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm([Routine? routine]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RoutineFormSheet(routine: routine, existing: _routines),
    );
    if (saved == true) {
      await _load(refresh: true);
      await NotificationService.syncSchedule();
    }
  }

  Future<void> _setStatus(Routine routine, String status) async {
    setState(() => _loading = true);
    try {
      await RoutineService.setOccurrenceStatus(
        routineId: routine.id,
        date: DateTime.now(),
        status: status,
      );
      await _load();
      await NotificationService.syncSchedule();
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the routine status.')),
        );
      }
    }
  }

  Future<void> _toggle(Routine routine) async {
    await RoutineService.setActive(routine, !routine.active);
    await _load(refresh: true);
    await NotificationService.syncSchedule();
  }

  Future<void> _delete(Routine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text(
          '“${routine.name}” and its completion history will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await RoutineService.deleteRoutine(routine.id);
    await _load(refresh: true);
    await NotificationService.syncSchedule();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily routines',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Reusable schedules with independent daily progress.',
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _loading ? null : () => _openForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_error!),
          trailing: TextButton(
            onPressed: () => _load(refresh: true),
            child: const Text('Retry'),
          ),
        )
      else if (!_loading && _routines.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.repeat_rounded, size: 48, color: AppColors.muted),
              SizedBox(height: 10),
              Text('No routines yet'),
              Text('Add a repeating schedule to build a daily habit.'),
            ],
          ),
        )
      else
        for (final routine in _routines) ...[
          _RoutineCard(
            routine: routine,
            occurrence: _occurrences[routine.id],
            onComplete: () => _setStatus(routine, 'completed'),
            onSkip: () => _setStatus(routine, 'skipped'),
            onEdit: () => _openForm(routine),
            onToggle: () => _toggle(routine),
            onDelete: () => _delete(routine),
          ),
          const SizedBox(height: 10),
        ],
    ],
  );
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.occurrence,
    required this.onComplete,
    required this.onSkip,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final Routine routine;
  final RoutineOccurrence? occurrence;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final today = routine.occursOn(DateTime.now());
    final status = occurrence?.status ?? (today ? 'scheduled' : 'not today');
    final color = _routineCategoryColor(routine.category);
    return shad.Card(
      padding: EdgeInsets.zero,
      borderColor: (routine.active ? AppColors.teal : AppColors.muted)
          .withValues(alpha: .25),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    _routineCategoryIcon(routine.category),
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 34,
                  ),
                  onSelected: (value) => switch (value) {
                    'edit' => onEdit(),
                    'toggle' => onToggle(),
                    _ => onDelete(),
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(routine.active ? 'Pause' : 'Resume'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              ' ${_formatMinutes(routine.startMinutes)}–'
              '${_formatMinutes(routine.endMinutes)} · ${_days(routine.activeDays)}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 7,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(routine.category),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(routine.active ? status : 'paused'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (today && status == 'scheduled') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      child: const Text('Skip today'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Complete'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Color _routineCategoryColor(String category) => switch (category) {
  'Exercise' => AppColors.coral,
  'Study' || 'Focus' => AppColors.teal,
  'Work' => AppColors.amber,
  _ => AppColors.indigo,
};

IconData _routineCategoryIcon(String category) => switch (category) {
  'Sleep' => Icons.bedtime_rounded,
  'Exercise' => Icons.directions_run_rounded,
  'Study' => Icons.school_rounded,
  'Work' => Icons.business_center_rounded,
  'Entertainment' => Icons.movie_rounded,
  'Personal' => Icons.person_rounded,
  'Custom' => Icons.tune_rounded,
  'Focus' => Icons.center_focus_strong_rounded,
  _ => Icons.event_rounded,
};

class RoutineFormSheet extends StatefulWidget {
  const RoutineFormSheet({super.key, this.routine, required this.existing});
  final Routine? routine;
  final List<Routine> existing;

  @override
  State<RoutineFormSheet> createState() => _RoutineFormSheetState();
}

class _RoutineFormSheetState extends State<RoutineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _category;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Set<int> _days;
  late DateTime _startsOn;
  DateTime? _endsOn;
  late bool _monitor;
  late bool _warnings;
  late int _reminderMinutes;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.routine;
    _name = TextEditingController(text: item?.name ?? '');
    _category = item?.category ?? 'Focus';
    _start = _tod(item?.startMinutes ?? 8 * 60);
    _end = _tod(item?.endMinutes ?? 9 * 60);
    _days = {...?item?.activeDays}
      ..addAll(item == null ? {1, 2, 3, 4, 5, 6, 7} : {});
    _startsOn = item?.startsOn ?? DateTime.now();
    _endsOn = item?.endsOn;
    _monitor = item?.monitorUsage ?? true;
    _warnings = item?.warnConflicts ?? true;
    _reminderMinutes = item?.reminderMinutes ?? 5;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay value) => value.hour * 60 + value.minute;

  Future<void> _pickTime(bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (value != null) setState(() => start ? _start = value : _end = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      RoutineValidation.validate(
        name: _name.text,
        category: _category,
        startMinutes: _minutes(_start),
        endMinutes: _minutes(_end),
        activeDays: _days,
        startsOn: _startsOn,
        endsOn: _endsOn,
      );
    } on FormatException catch (error) {
      setState(() => _error = error.message);
      return;
    }
    if (_warnings && !await _confirmConflicts()) return;
    setState(() => _saving = true);
    try {
      final item = widget.routine;
      if (item == null) {
        await RoutineService.createRoutine(
          name: _name.text,
          category: _category,
          startMinutes: _minutes(_start),
          endMinutes: _minutes(_end),
          activeDays: _days,
          startsOn: _startsOn,
          endsOn: _endsOn,
          monitorUsage: _monitor,
          warnConflicts: _warnings,
          reminderMinutes: _reminderMinutes,
        );
      } else {
        await RoutineService.updateRoutine(
          id: item.id,
          name: _name.text,
          category: _category,
          startMinutes: _minutes(_start),
          endMinutes: _minutes(_end),
          activeDays: _days,
          startsOn: _startsOn,
          endsOn: _endsOn,
          active: item.active,
          monitorUsage: _monitor,
          warnConflicts: _warnings,
          reminderMinutes: _reminderMinutes,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the routine.';
        });
      }
    }
  }

  Future<bool> _confirmConflicts() async {
    final routineConflicts = widget.existing
        .where(
          (item) =>
              item.id != widget.routine?.id &&
              item.active &&
              RoutineValidation.overlaps(
                firstStart: _minutes(_start),
                firstEnd: _minutes(_end),
                firstDays: _days,
                secondStart: item.startMinutes,
                secondEnd: item.endMinutes,
                secondDays: item.activeDays,
              ),
        )
        .toList();
    var date = DateTime(_startsOn.year, _startsOn.month, _startsOn.day);
    for (var i = 0; i < 7 && !_days.contains(date.weekday); i++) {
      date = date.add(const Duration(days: 1));
    }
    final startsAt = DateTime(
      date.year,
      date.month,
      date.day,
      _start.hour,
      _start.minute,
    );
    final endsAt = DateTime(
      date.year,
      date.month,
      date.day,
      _end.hour,
      _end.minute,
    );
    var activityConflicts = const <dynamic>[];
    try {
      activityConflicts = await ActivityService.getConflictingActivities(
        startsAt: startsAt,
        endsAt: endsAt,
      );
    } catch (_) {}
    if (routineConflicts.isEmpty && activityConflicts.isEmpty) return true;
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.coral,
            ),
            title: const Text('Routine conflicts found'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in routineConflicts)
                  Text('• Routine: ${item.name}'),
                for (final item in activityConflicts)
                  Text('• Activity: ${item.name}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Change schedule'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save anyway'),
              ),
            ],
          ),
        ) ??
        false;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.routine == null ? 'Add routine' : 'Edit routine',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Routine name',
                border: OutlineInputBorder(),
              ),
              validator: ActivityValidation.nameError,
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ActivityValidation.categories
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _reminderMinutes,
              decoration: const InputDecoration(
                labelText: 'Advance reminder',
                prefixIcon: Icon(Icons.notifications_active_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [0, 5, 10, 15, 30, 60]
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text(
                        minutes == 0
                            ? 'No advance reminder'
                            : minutes == 60
                            ? '1 hour before'
                            : '$minutes minutes before',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _reminderMinutes = value ?? 5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text('Start ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text('End ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Active days',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 5,
              children: List.generate(7, (index) {
                final day = index + 1;
                return FilterChip(
                  label: Text(const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                  selected: _days.contains(day),
                  onSelected: (selected) => setState(
                    () => selected ? _days.add(day) : _days.remove(day),
                  ),
                );
              }),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Starts on'),
              subtitle: Text(DateFormat.yMMMd().format(_startsOn)),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  initialDate: _startsOn,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 1825)),
                );
                if (value != null) setState(() => _startsOn = value);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ends on'),
              subtitle: Text(
                _endsOn == null
                    ? 'No end date'
                    : DateFormat.yMMMd().format(_endsOn!),
              ),
              trailing: _endsOn == null
                  ? const Icon(Icons.event_repeat_rounded)
                  : IconButton(
                      tooltip: 'Remove end date',
                      onPressed: () => setState(() => _endsOn = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  initialDate: _endsOn ?? _startsOn,
                  firstDate: _startsOn,
                  lastDate: DateTime.now().add(const Duration(days: 1825)),
                );
                if (value != null) setState(() => _endsOn = value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _monitor,
              onChanged: (v) => setState(() => _monitor = v),
              title: const Text('Monitor device usage'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _warnings,
              onChanged: (v) => setState(() => _warnings = v),
              title: const Text('Warn about conflicts'),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save routine'),
            ),
          ],
        ),
      ),
    ),
  );
}

TimeOfDay _tod(int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
String _formatMinutes(int minutes) =>
    DateFormat.jm().format(DateTime(2026, 1, 1, minutes ~/ 60, minutes % 60));
String _days(Set<int> days) {
  if (days.length == 7) return 'Every day';
  if (days.length == 5 && days.containsAll({1, 2, 3, 4, 5})) return 'Weekdays';
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final sorted = days.toList()..sort();
  return sorted.map((day) => names[day - 1]).join(', ');
}
