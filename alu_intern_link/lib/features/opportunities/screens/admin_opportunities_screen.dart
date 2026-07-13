import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../opportunity.dart';
import '../opportunity_providers.dart';

/// Second admin tab: every opportunity on the platform, with the power to
/// pull one down regardless of what its founder set - this is the "admin
/// decides what stays on the page" moderation control.
class AdminOpportunitiesScreen extends ConsumerWidget {
  const AdminOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesState = ref.watch(allOpportunitiesProvider);

    return opportunitiesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Something went wrong: $error')),
      data: (opportunities) {
        if (opportunities.isEmpty) {
          return const Center(child: Text('No opportunities have been posted yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: opportunities.length,
          itemBuilder: (context, index) => _ModerationCard(opportunity: opportunities[index]),
        );
      },
    );
  }
}

class _ModerationCard extends ConsumerWidget {
  const _ModerationCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium),
                      Text(opportunity.startupName, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                _ModerationStatusBadge(opportunity: opportunity),
              ],
            ),
            const SizedBox(height: 12),
            if (opportunity.removedByAdmin)
              OutlinedButton.icon(
                onPressed: () => ref.read(opportunityRepositoryProvider).restoreByAdmin(opportunity.id),
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restore'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => ref.read(opportunityRepositoryProvider).removeByAdmin(opportunity.id),
                icon: const Icon(Icons.block_rounded),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModerationStatusBadge extends StatelessWidget {
  const _ModerationStatusBadge({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = opportunity.removedByAdmin
        ? ('Removed', Colors.red)
        : opportunity.status == OpportunityStatus.open
        ? ('Open', Colors.green)
        : ('Closed', Colors.grey);

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
