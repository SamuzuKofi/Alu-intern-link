import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/initial_avatar.dart';
import '../startup.dart';
import '../startup_providers.dart';
import '../status_badge.dart';
import 'create_startup_screen.dart';
import 'startup_detail_screen.dart';

/// The middle tab for startup-role users: every startup they've
/// registered, plus a button to register another one at any time.
class MyStartupsScreen extends ConsumerWidget {
  const MyStartupsScreen({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsState = ref.watch(myStartupsProvider(ownerUid));

    return Scaffold(
      body: startupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (startups) {
          if (startups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("You haven't registered a startup yet."),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _openCreateScreen(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add a startup'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: startups.length,
            itemBuilder: (context, index) => _StartupCard(startup: startups[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Add startup'),
      ),
    );
  }

  void _openCreateScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CreateStartupScreen(ownerUid: ownerUid)));
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: startup.isArchived ? 0.5 : 1,
        child: ListTile(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => StartupDetailScreen(startupId: startup.id))),
          leading: InitialAvatar(name: startup.name),
          title: Text(startup.name),
          subtitle: Text(startup.isArchived ? '${startup.industry} · Archived' : startup.industry),
          trailing: StartupStatusBadge(status: startup.status),
        ),
      ),
    );
  }
}
