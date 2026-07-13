import 'package:cloud_firestore/cloud_firestore.dart';

import 'startup.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _firestore.collection('startups');

  /// A founder can own several startups, so this returns all of them.
  /// Sorted here in Dart (not via Firestore `orderBy`) so this query
  /// doesn't need its own composite index on top of the `ownerUid` filter.
  Stream<List<Startup>> watchStartupsForOwner(String ownerUid) {
    return _startups.where('ownerUid', isEqualTo: ownerUid).snapshots().map((snapshot) {
      final startups = snapshot.docs.map(Startup.fromFirestore).toList();
      startups.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return startups;
    });
  }

  Stream<Startup?> watchStartupById(String startupId) {
    return _startups.doc(startupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Startup.fromFirestore(doc);
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
      'isArchived': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Startup>> watchPendingStartups() {
    return _startups
        .where('status', isEqualTo: StartupStatus.pending.name)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Startup.fromFirestore).toList());
  }

  Future<void> setStatus(String startupId, StartupStatus status) {
    return _startups.doc(startupId).update({'status': status.name});
  }

  /// Delisting a startup also closes whatever it currently has open in
  /// Discover, so students don't keep applying to opportunities from a
  /// startup that just pulled itself off the platform. Both writes happen
  /// in one batch so they can't end up half-applied.
  Future<void> archiveStartup(String startupId) async {
    final batch = _firestore.batch();
    batch.update(_startups.doc(startupId), {'isArchived': true});

    final openOpportunities = await _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .where('status', isEqualTo: 'open')
        .get();
    for (final doc in openOpportunities.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }

    await batch.commit();
  }

  Future<void> unarchiveStartup(String startupId) {
    return _startups.doc(startupId).update({'isArchived': false});
  }
}
