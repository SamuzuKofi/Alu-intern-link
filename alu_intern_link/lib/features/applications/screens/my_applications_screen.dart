import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/widgets/initial_avatar.dart';
import '../application.dart';
import '../application_providers.dart';

/// Student tab: every opportunity they've applied to, with its current
/// status. Read-only - status changes come from the founder's Applicants
/// screen.
class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key, required this.studentUid});

  final String studentUid;

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  ApplicationStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final applicationsState = ref.watch(applicationsForStudentProvider(widget.studentUid));

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              _FilterChip(
                label: 'All',
                selected: _selectedStatus == null,
                onSelected: () => setState(() => _selectedStatus = null),
              ),
              const SizedBox(width: 8),
              for (final status in ApplicationStatus.values) ...[
                _FilterChip(
                  label: status.label,
                  selected: _selectedStatus == status,
                  onSelected: () => setState(() => _selectedStatus = status),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Expanded(
          child: applicationsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Something went wrong: $error')),
            data: (applications) {
              final filtered = _selectedStatus == null
                  ? applications
                  : applications.where((a) => a.status == _selectedStatus).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("Nothing here yet."));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _ApplicationCard(application: filtered[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(color: selected ? colorScheme.onPrimary : colorScheme.onSurface),
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
        leading: InitialAvatar(name: application.startupName),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
