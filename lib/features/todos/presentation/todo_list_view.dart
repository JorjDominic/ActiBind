import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/activities/presentation/widgets/activity_schedule_view.dart';
import 'package:actibind/features/activities/services/activity_service.dart';
import 'package:actibind/features/todos/models/todo_item.dart';
import 'package:actibind/features/todos/services/todo_service.dart';
import 'package:actibind/features/todos/services/todo_validation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  List<TodoItem> _todos = const [];
  String _filter = 'open';
  bool _loading = true;
  String? _error;

  List<TodoItem> get _visible => switch (_filter) {
    'open' => _todos.where((todo) => !todo.completed).toList(),
    'done' => _todos.where((todo) => todo.completed).toList(),
    _ => _todos,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final todos = await TodoService.getTodos();
      if (mounted) setState(() => _todos = todos);
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('Supabase has not been initialized')) {
      return 'Task sync is available after the app starts normally.';
    }
    if (value.contains('todos') && value.contains('schema cache')) {
      return 'The Tasks database migration has not been applied yet.';
    }
    return 'Could not sync tasks. Check your connection and try again.';
  }

  Future<void> _openForm([TodoItem? todo]) async {
    final draft = await showModalBottomSheet<TodoDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TodoFormSheet(todo: todo),
    );
    if (draft == null || !mounted) return;
    await _mutate(() async {
      if (todo == null) {
        await TodoService.createTodo(
          title: draft.title,
          notes: draft.notes,
          priority: draft.priority,
          dueDate: draft.dueDate,
        );
      } else {
        await TodoService.updateTodo(
          id: todo.id,
          title: draft.title,
          notes: draft.notes,
          priority: draft.priority,
          dueDate: draft.dueDate,
        );
      }
    }, success: todo == null ? 'Task added.' : 'Task updated.');
  }

  Future<void> _toggle(TodoItem todo, bool completed) => _mutate(
    () => TodoService.setCompleted(todo, completed),
    success: completed ? 'Task completed.' : 'Task reopened.',
  );

  Future<void> _delete(TodoItem todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${todo.title}” will be permanently removed.'),
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
    if (confirmed == true) {
      await _mutate(
        () => TodoService.deleteTodo(todo.id),
        success: 'Task deleted.',
      );
    }
  }

  Future<void> _schedule(TodoItem todo) async {
    final draft = await showModalBottomSheet<ActivityDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ActivityFormSheet(
        initialDate: todo.dueDate ?? DateTime.now(),
        initialName: todo.title,
        initialCategory: 'Personal',
      ),
    );
    if (draft == null || !mounted) return;
    await _mutate(() async {
      await ActivityService.createActivity(
        name: draft.name,
        category: draft.category,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        repeat: draft.repeat,
        monitorUsage: draft.monitorUsage,
        warnConflicts: draft.warnConflicts,
      );
      if (!todo.completed) await TodoService.setCompleted(todo, true);
    }, success: 'Task added to your schedule and completed.');
  }

  Future<void> _mutate(
    Future<void> Function() action, {
    required String success,
  }) async {
    setState(() => _loading = true);
    try {
      await action();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update task: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _todos.where((todo) => !todo.completed).length;
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
                    'Quick tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    openCount == 1
                        ? '1 task remaining'
                        : '$openCount tasks remaining',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'open', label: Text('Open')),
            ButtonSegment(value: 'all', label: Text('All')),
            ButtonSegment(value: 'done', label: Text('Completed')),
          ],
          selected: {_filter},
          onSelectionChanged: (value) => setState(() => _filter = value.first),
        ),
        const SizedBox(height: 14),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_off_rounded),
            title: Text(_error!),
            trailing: TextButton(onPressed: _load, child: const Text('Retry')),
          )
        else if (!_loading && _visible.isEmpty)
          _EmptyTasks(filter: _filter, onAdd: () => _openForm())
        else
          for (final todo in _visible) ...[
            _TodoCard(
              todo: todo,
              onChanged: (value) => _toggle(todo, value),
              onEdit: () => _openForm(todo),
              onDelete: () => _delete(todo),
              onSchedule: () => _schedule(todo),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onSchedule,
  });

  final TodoItem todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final color = switch (todo.priority) {
      'high' => AppColors.coral,
      'low' => AppColors.teal,
      _ => AppColors.amber,
    };
    final overdue =
        !todo.completed &&
        todo.dueDate != null &&
        DateUtils.dateOnly(
          todo.dueDate!,
        ).isBefore(DateUtils.dateOnly(DateTime.now()));
    return shad.Card(
      borderColor: color.withValues(alpha: .24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 11, 8, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: todo.completed,
              onChanged: (value) => onChanged(value ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.completed
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (todo.notes != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        todo.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _TaskTag(
                          label: '${todo.priority} priority',
                          color: color,
                        ),
                        if (todo.dueDate != null)
                          _TaskTag(
                            label: overdue
                                ? 'Overdue · ${DateFormat('MMM d').format(todo.dueDate!)}'
                                : 'Due ${DateFormat('MMM d').format(todo.dueDate!)}',
                            color: overdue ? AppColors.coral : AppColors.indigo,
                          ),
                        if (!todo.completed)
                          TextButton.icon(
                            onPressed: onSchedule,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                            ),
                            label: const Text('Schedule'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Task actions',
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTag extends StatelessWidget {
  const _TaskTag({required this.label, required this.color});
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

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.filter, required this.onAdd});
  final String filter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 42),
    child: Column(
      children: [
        const Icon(Icons.task_alt_rounded, size: 46, color: AppColors.teal),
        const SizedBox(height: 10),
        Text(
          filter == 'done' ? 'No completed tasks yet' : 'You’re all caught up',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 5),
        Text(
          filter == 'done'
              ? 'Completed tasks will appear here.'
              : 'Add a quick task whenever something comes to mind.',
          textAlign: TextAlign.center,
        ),
        if (filter != 'done') ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add task'),
          ),
        ],
      ],
    ),
  );
}

class TodoDraft {
  const TodoDraft({
    required this.title,
    required this.priority,
    this.notes,
    this.dueDate,
  });
  final String title;
  final String? notes;
  final String priority;
  final DateTime? dueDate;
}

class TodoFormSheet extends StatefulWidget {
  const TodoFormSheet({super.key, this.todo});
  final TodoItem? todo;

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late String _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.todo?.title ?? '');
    _notes = TextEditingController(text: widget.todo?.notes ?? '');
    _priority = widget.todo?.priority ?? 'medium';
    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'Select optional due date',
    );
    if (date != null) setState(() => _dueDate = DateUtils.dateOnly(date));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    try {
      TodoValidation.validate(
        title: _title.text,
        priority: _priority,
        notes: _notes.text,
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    Navigator.pop(
      context,
      TodoDraft(
        title: _title.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      18,
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
              widget.todo == null ? 'Add task' : 'Edit task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              autofocus: widget.todo == null,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'What needs to be done?',
              ),
              validator: TodoValidation.titleError,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notes,
              maxLength: 1000,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(
                      _dueDate == null
                          ? 'Add due date'
                          : DateFormat('MMM d, y').format(_dueDate!),
                    ),
                  ),
                ),
                if (_dueDate != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Remove due date',
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _save,
              child: Text(widget.todo == null ? 'Add task' : 'Save changes'),
            ),
          ],
        ),
      ),
    ),
  );
}
