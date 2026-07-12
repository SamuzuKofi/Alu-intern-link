import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../applications/screens/applicants_screen.dart';
import '../opportunity.dart';
import '../opportunity_providers.dart';

/// Embedded in the founder's startup profile: the list of opportunities
/// they've posted, with a switch to open/close each one.
class MyOpportunitiesSection extends ConsumerWidget {
  const MyOpportunitiesSection({super.key, required this.startupId});

  final String startupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesState = ref.watch(opportunitiesForStartupProvider(startupId));

    return opportunitiesState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Could not load opportunities: $error'),
      ),
      data: (opportunities) {
        if (opportunities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("You haven't posted any opportunities yet."),
          );
        }
        return Column(
          children: opportunities.map((o) => _OpportunityRow(opportunity: o)).toList(),
        );
      },
    );
  }
}

class _OpportunityRow extends ConsumerWidget {
  const _OpportunityRow({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = opportunity.status == OpportunityStatus.open;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ApplicantsScreen(opportunity: opportunity)),
        ),
        title: Text(opportunity.title),
        subtitle: Text('${opportunity.category.label} · ${opportunity.location.label} · tap to view applicants'),
        trailing: Switch(
          value: isOpen,
          onChanged: (value) {
            ref
                .read(opportunityRepositoryProvider)
                .setStatus(opportunity.id, value ? OpportunityStatus.open : OpportunityStatus.closed);
          },
        ),
      ),
    );
  }
}
