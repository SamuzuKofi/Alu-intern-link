import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/initial_avatar.dart';
import '../../opportunities/screens/create_opportunity_screen.dart';
import '../../opportunities/screens/my_opportunities_section.dart';
import '../startup.dart';
import '../startup_providers.dart';

/// The middle tab for startup-role users. Shows a create form if they
/// don't have a startup yet, otherwise shows its profile and verification
/// status.
class MyStartupScreen extends ConsumerWidget {
  const MyStartupScreen({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupState = ref.watch(myStartupProvider(ownerUid));

    return startupState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Something went wrong: $error')),
      data: (startup) {
        if (startup == null) return _CreateStartupForm(ownerUid: ownerUid);
        return _StartupProfileView(startup: startup);
      },
    );
  }
}

class _CreateStartupForm extends ConsumerStatefulWidget {
  const _CreateStartupForm({required this.ownerUid});

  final String ownerUid;

  @override
  ConsumerState<_CreateStartupForm> createState() => _CreateStartupFormState();
}

class _CreateStartupFormState extends ConsumerState<_CreateStartupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await ref.read(startupRepositoryProvider).createStartup(
      ownerUid: widget.ownerUid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      industry: _industryController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
    );
    // myStartupProvider will pick up the new document automatically and
    // switch this tab over to _StartupProfileView, so no navigation here.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Set up your startup', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'An ALU admin will review this before you can post opportunities.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Startup name'),
              validator: (v) => Validators.required(v, label: 'Startup name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _industryController,
              decoration: const InputDecoration(
                labelText: 'Industry',
                hintText: 'e.g. FinTech, EdTech, Agriculture',
              ),
              validator: (v) => Validators.required(v, label: 'Industry'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What does your startup do?',
              ),
              validator: (v) => Validators.required(v, label: 'Description'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (optional)',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit for review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupProfileView extends StatelessWidget {
  const _StartupProfileView({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    final isVerified = startup.status == StartupStatus.verified;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            InitialAvatar(name: startup.name, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startup.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(startup.industry, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            _StatusBadge(status: startup.status),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Text(startup.description),
        if (startup.website != null) ...[
          const SizedBox(height: 16),
          Text(startup.website!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
        if (startup.status == StartupStatus.pending) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Waiting for an ALU admin to verify this startup.'),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Your opportunities', style: Theme.of(context).textTheme.titleMedium),
            ),
            if (isVerified)
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CreateOpportunityScreen(startup: startup)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Post'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isVerified)
          const Text('You can post opportunities once your startup is verified.')
        else
          MyOpportunitiesSection(startupId: startup.id),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StartupStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StartupStatus.pending => ('Pending', Colors.orange),
      StartupStatus.verified => ('Verified', Colors.green),
      StartupStatus.rejected => ('Rejected', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
