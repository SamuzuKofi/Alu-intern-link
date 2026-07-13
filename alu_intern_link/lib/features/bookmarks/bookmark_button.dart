import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../opportunities/opportunity.dart';
import 'bookmark_providers.dart';

/// A tappable bookmark icon that saves/un-saves [opportunity] for
/// [studentUid]. Only meant to be shown to student accounts - callers
/// decide whether to render it based on role.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.studentUid, required this.opportunity});

  final String studentUid;
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarkedState = ref.watch(isBookmarkedProvider((studentUid, opportunity.id)));
    final isBookmarked = isBookmarkedState.value ?? false;

    return IconButton(
      icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
      color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
      onPressed: () {
        final repository = ref.read(bookmarkRepositoryProvider);
        if (isBookmarked) {
          repository.removeBookmark(studentUid, opportunity.id);
        } else {
          repository.addBookmark(studentUid, opportunity);
        }
      },
    );
  }
}
