import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../applications/application_providers.dart';
import '../../applications/screens/apply_screen.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';
import '../opportunity.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserState = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(opportunity.startupName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(opportunity.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Posted by ${opportunity.startupName}', style: Theme.of(context).textTheme.bodyMedium),
            if (opportunity.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                timeago.format(opportunity.createdAt!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(opportunity.category.label)),
                Chip(label: Text(opportunity.location.label)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(opportunity.description),
            if (opportunity.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Skills required', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opportunity.skillsRequired.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
            const SizedBox(height: 32),
            appUserState.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (appUser) {
                if (appUser == null || appUser.role != UserRole.student) {
                  return const SizedBox.shrink();
                }
                return _ApplySection(opportunity: opportunity, appUser: appUser);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Only rendered for students. Watches whether they've already applied to
/// this specific opportunity and shows either an Apply button or their
/// current application status.
class _ApplySection extends ConsumerWidget {
  const _ApplySection({required this.opportunity, required this.appUser});

  final Opportunity opportunity;
  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingApplicationState = ref.watch(
      myApplicationForOpportunityProvider((opportunity.id, appUser.uid)),
    );

    return existingApplicationState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Something went wrong: $error'),
      data: (application) {
        if (application != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(child: Text('You applied - status: ${application.status.label}')),
                ],
              ),
            ),
          );
        }

        if (opportunity.status == OpportunityStatus.closed) {
          return const Text('This opportunity is no longer accepting applications.');
        }

        return ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplyScreen(opportunity: opportunity, appUser: appUser),
            ),
          ),
          child: const Text('Apply'),
        );
      },
    );
  }
}
