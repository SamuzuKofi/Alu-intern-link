import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'bookmark.dart';
import 'bookmark_repository.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository(firestore: ref.watch(firestoreProvider));
});

/// The `(studentUid, opportunityId)` record is the family key - both
/// pieces are needed to know which bookmark to watch. `.autoDispose`
/// clears cached state once nobody's watching, so a stale error from an
/// earlier session can't linger after sign-out/sign-in.
final isBookmarkedProvider = StreamProvider.autoDispose
    .family<bool, (String studentUid, String opportunityId)>((ref, key) {
      final (studentUid, opportunityId) = key;
      return ref.watch(bookmarkRepositoryProvider).watchIsBookmarked(studentUid, opportunityId);
    });

final bookmarksForStudentProvider = StreamProvider.autoDispose.family<List<Bookmark>, String>((
  ref,
  studentUid,
) {
  return ref.watch(bookmarkRepositoryProvider).watchBookmarksForStudent(studentUid);
});
