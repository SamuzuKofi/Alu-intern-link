import 'package:cloud_firestore/cloud_firestore.dart';

import 'startup.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _firestore.collection('startups');

  /// A founder owns at most one startup, so this looks up their doc by
  /// `ownerUid` instead of needing them to remember a separate startup id.
  Stream<Startup?> watchStartupForOwner(String ownerUid) {
    return _startups.where('ownerUid', isEqualTo: ownerUid).limit(1).snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) return null;
      return Startup.fromFirestore(snapshot.docs.first);
    });
  }

  Future<void> createStartup({
    required String ownerUid,
    required String name,
    required String description,
    required String industry,
    String? website,
  }) {
    return _startups.add({
      'name': name,
      'description': description,
      'industry': industry,
      'website': website,
      'ownerUid': ownerUid,
      'status': StartupStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Startup>> watchPendingStartups() {
    return _startups
        .where('status', isEqualTo: StartupStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Startup.fromFirestore).toList());
  }

  Future<void> setStatus(String startupId, StartupStatus status) {
    return _startups.doc(startupId).update({'status': status.name});
  }
}
