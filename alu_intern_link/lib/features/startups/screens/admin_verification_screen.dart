import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../startup.dart';
import '../startup_providers.dart';

/// Middle tab for admin accounts: a queue of startups waiting to be
/// verified before their founders can post opportunities.
class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingState = ref.watch(pendingStartupsProvider);

    return pendingState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Something went wrong: $error')),
      data: (pendingStartups) {
        if (pendingStartups.isEmpty) {
          return const Center(child: Text('No startups waiting for review 🎉'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingStartups.length,
          itemBuilder: (context, index) {
            return _PendingStartupCard(startup: pendingStartups[index]);
          },
        );
      },
    );
  }
}

class _PendingStartupCard extends ConsumerStatefulWidget {
  const _PendingStartupCard({required this.startup});

  final Startup startup;

  @override
  ConsumerState<_PendingStartupCard> createState() => _PendingStartupCardState();
}

class _PendingStartupCardState extends ConsumerState<_PendingStartupCard> {
  bool _isUpdating = false;

  Future<void> _setStatus(StartupStatus status) async {
    setState(() => _isUpdating = true);
    await ref.read(startupRepositoryProvider).setStatus(widget.startup.id, status);
    // No need to reset _isUpdating: pendingStartupsProvider will remove
    // this startup from the list as soon as its status changes, so this
    // whole card disappears from the screen.
  }

  @override
  Widget build(BuildContext context) {
    final startup = widget.startup;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(startup.industry, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(startup.description),
            if (startup.website != null) ...[
              const SizedBox(height: 8),
              Text(startup.website!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ],
            const SizedBox(height: 16),
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _setStatus(StartupStatus.rejected),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setStatus(StartupStatus.verified),
                      child: const Text('Verify'),
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
