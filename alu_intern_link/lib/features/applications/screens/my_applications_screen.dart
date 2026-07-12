import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../application.dart';
import '../application_providers.dart';

/// Student tab: every opportunity they've applied to, with its current
/// status. Read-only - status changes come from the founder's Applicants
/// screen.
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key, required this.studentUid});

  final String studentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsState = ref.watch(applicationsForStudentProvider(studentUid));

    return applicationsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Something went wrong: $error')),
      data: (applications) {
        if (applications.isEmpty) {
          return const Center(child: Text("You haven't applied to anything yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) => _ApplicationCard(application: applications[index]),
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(application.opportunityTitle),
        subtitle: Text(
          application.createdAt != null
              ? '${application.startupName} · Applied ${timeago.format(application.createdAt!)}'
              : application.startupName,
        ),
        trailing: _StatusBadge(status: application.status),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ApplicationStatus.pending => Colors.orange,
      ApplicationStatus.reviewed => Colors.blue,
      ApplicationStatus.accepted => Colors.green,
      ApplicationStatus.rejected => Colors.red,
    };

    return Chip(
      label: Text(status.label, style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }
}
