import 'package:cloud_firestore/cloud_firestore.dart';

import 'opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');

  /// Feeds the Discover tab. We fetch every open opportunity and let the
  /// screen filter by search text/category in memory - simple, and fine
  /// at the scale of one university's worth of postings. A production
  /// version at bigger scale would move search server-side (e.g. Algolia).
  Stream<List<Opportunity>> watchOpenOpportunities() {
    return _opportunities
        .where('status', isEqualTo: OpportunityStatus.open.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Opportunity.fromFirestore).toList());
  }

  Stream<List<Opportunity>> watchOpportunitiesForStartup(String startupId) {
    return _opportunities
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Opportunity.fromFirestore).toList());
  }

  Future<void> createOpportunity({
    required String startupId,
    required String startupName,
    required String postedByUid,
    required String title,
    required String description,
    required OpportunityCategory category,
    required OpportunityLocationType location,
    required List<String> skillsRequired,
  }) {
    return _opportunities.add({
      'startupId': startupId,
      'startupName': startupName,
      'postedByUid': postedByUid,
      'title': title,
      'description': description,
      'category': category.name,
      'location': location.name,
      'skillsRequired': skillsRequired,
      'status': OpportunityStatus.open.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String opportunityId, OpportunityStatus status) {
    return _opportunities.doc(opportunityId).update({'status': status.name});
  }
}
