import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/family/models/family_models.dart';
import 'package:actibind/features/family/presentation/pages/child_profile_page.dart';
import 'package:actibind/features/family/services/child_profile_service.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<ChildProfile> _profiles = const [];
  bool _loading = true;
  String? _error;

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
      final profiles = await ChildProfileService.getProfiles();
      if (mounted) setState(() => _profiles = profiles);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([ChildProfile? profile]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProfileFormSheet(profile: profile),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(ChildProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${profile.name}?'),
        content: const Text('This child profile will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ChildProfileService.deleteProfile(profile.id);
      await _load();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not complete that action: $error')),
    );
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Family',
            subtitle: 'Manage child profiles, devices, and screen time',
            trailing: _ActiveBadge(),
          ),
          const SizedBox(height: 20),
          _FamilySummary(profiles: _profiles),
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
                '${_profiles.length} ${_profiles.length == 1 ? 'profile' : 'profiles'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorState(message: _error!, onRetry: _load)
          else if (_profiles.isEmpty)
            const _EmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = _profiles
                    .map(
                      (child) => _ChildCard(
                        child: child,
                        onEdit: () => _openForm(child),
                        onDelete: () => _delete(child),
                      ),
                    )
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
            onPressed: _loading ? null : () => _openForm(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add Child'),
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
                          'Hand over this device safely',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Apply a child’s restrictions while they use this device.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _profiles.isEmpty
                              ? null
                              : () => showModalBottomSheet<void>(
                                  context: context,
                                  useSafeArea: true,
                                  builder: (_) =>
                                      _ChildModeSheet(profiles: _profiles),
                                ),
                          icon: const Icon(Icons.lock_clock_rounded),
                          label: const Text(
                            'Set up Child Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    ),
  );
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
  const _FamilySummary({required this.profiles});
  final List<ChildProfile> profiles;
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        '${profiles.length}',
        'Children',
        Icons.people_alt_rounded,
        AppColors.indigo,
      ),
      (
        '${profiles.where((p) => p.connected).length}',
        'Linked devices',
        Icons.devices_rounded,
        AppColors.teal,
      ),
      (
        '${profiles.where((p) => p.restrictionsActive).length}',
        'Restrictions',
        Icons.shield_rounded,
        AppColors.coral,
      ),
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
  const _ChildCard({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });
  final ChildProfile child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    child.device,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Today: ${child.screenTime}  •  ${child.restrictionsActive ? 'Restrictions active' : 'No restrictions'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Profile actions',
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileFormSheet extends StatefulWidget {
  const _ProfileFormSheet({this.profile});
  final ChildProfile? profile;
  @override
  State<_ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<_ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _device;
  late String _ageRange;
  late bool _connected;
  late bool _restrictions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile?.name ?? '');
    _device = TextEditingController(
      text: profile?.device == 'No device linked' ? '' : profile?.device ?? '',
    );
    _ageRange = profile?.ageRange ?? '9-12';
    _connected = profile?.connected ?? false;
    _restrictions = profile?.restrictionsActive ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _device.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.profile == null) {
        await ChildProfileService.createProfile(
          name: _name.text,
          ageRange: _ageRange,
        );
      } else {
        await ChildProfileService.updateProfile(
          id: widget.profile!.id,
          name: _name.text,
          ageRange: _ageRange,
          device: _device.text,
          connected: _connected,
          restrictionsActive: _restrictions,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.profile == null ? 'Add a child' : 'Edit child profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Child name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the child’s name'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _ageRange,
              decoration: const InputDecoration(
                labelText: 'Age range',
                border: OutlineInputBorder(),
              ),
              items: const ['Under 6', '6-8', '9-12', '13-15', '16-17']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _ageRange = value ?? _ageRange),
            ),
            if (widget.profile != null) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _device,
                decoration: const InputDecoration(
                  labelText: 'Device name',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Device connected'),
                value: _connected,
                onChanged: (value) => setState(() => _connected = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Restrictions active'),
                value: _restrictions,
                onChanged: (value) => setState(() => _restrictions = value),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Saving…'
                    : widget.profile == null
                    ? 'Create Profile'
                    : 'Save Changes',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChildModeSheet extends StatefulWidget {
  const _ChildModeSheet({required this.profiles});
  final List<ChildProfile> profiles;
  @override
  State<_ChildModeSheet> createState() => _ChildModeSheetState();
}

class _ChildModeSheetState extends State<_ChildModeSheet> {
  late String _childId = widget.profiles.first.id;
  String _duration = '1 hour';
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Set up Child Mode',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: _childId,
          decoration: const InputDecoration(
            labelText: 'Child profile',
            border: OutlineInputBorder(),
          ),
          items: widget.profiles
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          onChanged: (value) => setState(() => _childId = value ?? _childId),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _duration,
          decoration: const InputDecoration(
            labelText: 'Duration',
            border: OutlineInputBorder(),
          ),
          items: const ['30 minutes', '1 hour', '2 hours', 'Custom']
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) => setState(() => _duration = value ?? _duration),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.lock_rounded),
          label: const Text('Start Child Mode'),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Icon(Icons.family_restroom_rounded, size: 42, color: AppColors.muted),
        SizedBox(height: 10),
        Text(
          'No child profiles yet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        Text(
          'Add a child to start managing their screen time.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.35),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Text(
          'Could not load child profiles',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
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
  );
}
