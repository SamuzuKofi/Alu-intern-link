import 'package:cloud_firestore/cloud_firestore.dart';

import '../opportunities/opportunity.dart';
import 'bookmark.dart';

class BookmarkRepository {
  BookmarkRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _bookmarks =>
      _firestore.collection('bookmarks');

  Stream<bool> watchIsBookmarked(String studentUid, String opportunityId) {
    final id = Bookmark.idFor(studentUid: studentUid, opportunityId: opportunityId);
    return _bookmarks.doc(id).snapshots().map((doc) => doc.exists);
  }

  Future<void> addBookmark(String studentUid, Opportunity opportunity) {
    final id = Bookmark.idFor(studentUid: studentUid, opportunityId: opportunity.id);
    return _bookmarks.doc(id).set({
      'studentUid': studentUid,
      'opportunityId': opportunity.id,
      'opportunityTitle': opportunity.title,
      'startupName': opportunity.startupName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String studentUid, String opportunityId) {
    final id = Bookmark.idFor(studentUid: studentUid, opportunityId: opportunityId);
    return _bookmarks.doc(id).delete();
  }

  Stream<List<Bookmark>> watchBookmarksForStudent(String studentUid) {
    return _bookmarks
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Bookmark.fromFirestore).toList());
  }
}
