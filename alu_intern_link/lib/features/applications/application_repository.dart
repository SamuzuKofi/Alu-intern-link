import 'package:cloud_firestore/cloud_firestore.dart';

import 'application.dart';

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  /// Lets the UI check "have I already applied to this?" before showing
  /// the Apply button, so a student can't submit the same application
  /// twice.
  Stream<Application?> watchApplicationFor(String opportunityId, String studentUid) {
    return _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return Application.fromFirestore(snapshot.docs.first);
        });
  }

  Future<void> apply({
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String studentUid,
    required String studentName,
    required String studentEmail,
    required String coverNote,
  }) {
    return _applications.add({
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'coverNote': coverNote,
      'status': ApplicationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Application>> watchApplicationsForStudent(String studentUid) {
    return _applications
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Application.fromFirestore).toList());
  }

  Stream<List<Application>> watchApplicationsForOpportunity(String opportunityId) {
    return _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Application.fromFirestore).toList());
  }

  Future<void> setStatus(String applicationId, ApplicationStatus status) {
    return _applications.doc(applicationId).update({'status': status.name});
  }
}
