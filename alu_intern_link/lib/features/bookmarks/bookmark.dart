import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a `bookmarks/{id}` Firestore document, where the id is always
/// `"${studentUid}_${opportunityId}"`. Using a predictable id (instead of
/// an auto-generated one) means "is this saved?" and "un-save this" are
/// both a direct document lookup by id - no query needed.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.studentUid,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    this.createdAt,
  });

  final String id;
  final String studentUid;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final DateTime? createdAt;

  static String idFor({required String studentUid, required String opportunityId}) {
    return '${studentUid}_$opportunityId';
  }

  factory Bookmark.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Bookmark(
      id: doc.id,
      studentUid: data['studentUid'] as String? ?? '',
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
