import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/initial_avatar.dart';
import '../../opportunities/screens/create_opportunity_screen.dart';
import '../../opportunities/screens/my_opportunities_section.dart';
import '../startup.dart';
import '../startup_providers.dart';
import '../status_badge.dart';

class StartupDetailScreen extends ConsumerWidget {
  const StartupDetailScreen({super.key, required this.startupId});

  final String startupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupState = ref.watch(startupByIdProvider(startupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Startup profile')),
      body: startupState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (startup) {
          if (startup == null) {
            return const Center(child: Text('This startup no longer exists.'));
          }
          return _StartupDetailBody(startup: startup);
        },
      ),
    );
  }
}

class _StartupDetailBody extends ConsumerWidget {
  const _StartupDetailBody({required this.startup});

  final Startup startup;

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delist this startup?'),
        content: const Text(
          'This hides it (and closes any of its open opportunities) from Discover. '
          'You can bring it back later.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delist'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(startupRepositoryProvider).archiveStartup(startup.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = startup.status == StartupStatus.verified;
    final canPost = isVerified && !startup.isArchived;

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
            StartupStatusBadge(status: startup.status),
          ],
        ),
        if (startup.isArchived) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('Delisted', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
        const SizedBox(height: 16),
        Text(startup.description),
        if (startup.website != null) ...[
          const SizedBox(height: 16),
          Text(startup.website!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
        if (startup.status == StartupStatus.pending && !startup.isArchived) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Waiting for an ALU admin to verify this startup.')),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => startup.isArchived
              ? ref.read(startupRepositoryProvider).unarchiveStartup(startup.id)
              : _confirmArchive(context, ref),
          icon: Icon(startup.isArchived ? Icons.restore_rounded : Icons.archive_outlined),
          label: Text(startup.isArchived ? 'Bring back' : 'Delist startup'),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Your opportunities', style: Theme.of(context).textTheme.titleMedium),
            ),
            if (canPost)
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
        if (!canPost)
          Text(
            startup.isArchived
                ? 'Bring this startup back to post new opportunities.'
                : 'You can post opportunities once your startup is verified.',
          )
        else
          MyOpportunitiesSection(startupId: startup.id),
      ],
    );
  }
}
