import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/widgets/initial_avatar.dart';
import '../../applications/application_providers.dart';
import '../../applications/screens/apply_screen.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';
import '../../bookmarks/bookmark_button.dart';
import '../opportunity.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserState = ref.watch(currentAppUserProvider);
    final appUser = appUserState.value;
    final isStudent = appUser != null && appUser.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity details'),
        actions: [
          if (isStudent) BookmarkButton(studentUid: appUser.uid, opportunity: opportunity),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                InitialAvatar(name: opportunity.startupName, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.title, style: Theme.of(context).textTheme.titleLarge),
                      Text(opportunity.startupName, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    _InfoRow(icon: opportunity.category.icon, label: opportunity.category.label),
                    const Divider(height: 1),
                    _InfoRow(icon: Icons.place_outlined, label: opportunity.location.label),
                    if (opportunity.createdAt != null) ...[
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        label: 'Posted ${timeago.format(opportunity.createdAt!)}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('About', style: Theme.of(context).textTheme.titleSmall),
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
          ],
        ),
      ),
      bottomNavigationBar: isStudent
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: _ApplySection(opportunity: opportunity, appUser: appUser),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
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
          return const Text(
            'This opportunity is no longer accepting applications.',
            textAlign: TextAlign.center,
          );
        }

        return FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplyScreen(opportunity: opportunity, appUser: appUser),
            ),
          ),
          child: const Text('Apply now'),
        );
      },
    );
  }
}
