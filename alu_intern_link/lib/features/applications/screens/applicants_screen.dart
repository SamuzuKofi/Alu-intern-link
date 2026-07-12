import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../opportunities/opportunity.dart';
import '../application.dart';
import '../application_providers.dart';

/// Founder tab: everyone who applied to one specific opportunity, with a
/// dropdown to move each applicant through pending -> reviewed ->
/// accepted/rejected.
class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsState = ref.watch(applicationsForOpportunityProvider(opportunity.id));

    return Scaffold(
      appBar: AppBar(title: Text('Applicants · ${opportunity.title}')),
      body: applicantsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (applicants) {
          if (applicants.isEmpty) {
            return const Center(child: Text('No applicants yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applicants.length,
            itemBuilder: (context, index) => _ApplicantCard(application: applicants[index]),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.studentName.isNotEmpty ? application.studentName : application.studentEmail,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(application.studentEmail, style: Theme.of(context).textTheme.bodySmall),
            if (application.createdAt != null)
              Text(
                'Applied ${timeago.format(application.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Text(application.coverNote),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                DropdownButton<ApplicationStatus>(
                  value: application.status,
                  items: ApplicationStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (status) {
                    if (status == null) return;
                    ref.read(applicationRepositoryProvider).setStatus(application.id, status);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
