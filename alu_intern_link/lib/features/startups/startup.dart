import 'package:cloud_firestore/cloud_firestore.dart';

enum StartupStatus {
  pending,
  verified,
  rejected;

  static StartupStatus fromName(String? name) {
    for (final status in StartupStatus.values) {
      if (status.name == name) return status;
    }
    return StartupStatus.pending;
  }
}

/// Mirrors a `startups/{id}` Firestore document.
///
/// Every startup starts out `pending` and only becomes visible for posting
/// opportunities once an admin sets it to `verified` — this is the gate
/// that keeps random accounts from posing as recognized ALU startups.
class Startup {
  const Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.ownerUid,
    this.website,
    this.status = StartupStatus.pending,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String industry;
  final String ownerUid;
  final String? website;
  final StartupStatus status;
  final DateTime? createdAt;

  factory Startup.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Startup(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      industry: data['industry'] as String? ?? '',
      ownerUid: data['ownerUid'] as String? ?? '',
      website: data['website'] as String?,
      status: StartupStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
