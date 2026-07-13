import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/initial_avatar.dart';
import '../../opportunities/opportunity_providers.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';
import '../bookmark.dart';
import '../bookmark_providers.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key, required this.studentUid});

  final String studentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksState = ref.watch(bookmarksForStudentProvider(studentUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: bookmarksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const Center(child: Text("You haven't saved anything yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) => _SavedCard(bookmark: bookmarks[index]),
          );
        },
      ),
    );
  }
}

class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: InitialAvatar(name: bookmark.startupName),
        title: Text(bookmark.opportunityTitle),
        subtitle: Text(bookmark.startupName),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openOpportunity(context, ref),
      ),
    );
  }

  Future<void> _openOpportunity(BuildContext context, WidgetRef ref) async {
    final opportunity = await ref.read(opportunityByIdProvider(bookmark.opportunityId).future);
    if (!context.mounted) return;

    if (opportunity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This opportunity is no longer available.')));
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opportunity)));
  }
}
