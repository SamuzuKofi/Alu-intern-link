import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityCategory {
  softwareDevelopment('Software Development'),
  design('Design'),
  marketing('Marketing'),
  operations('Operations'),
  research('Research'),
  businessAnalysis('Business Analysis'),
  contentCreation('Content Creation'),
  communityManagement('Community Management');

  const OpportunityCategory(this.label);
  final String label;

  static OpportunityCategory fromName(String? name) {
    for (final category in OpportunityCategory.values) {
      if (category.name == name) return category;
    }
    return OpportunityCategory.softwareDevelopment;
  }
}

enum OpportunityLocationType {
  remote('Remote'),
  onCampus('On Campus'),
  hybrid('Hybrid');

  const OpportunityLocationType(this.label);
  final String label;

  static OpportunityLocationType fromName(String? name) {
    for (final location in OpportunityLocationType.values) {
      if (location.name == name) return location;
    }
    return OpportunityLocationType.remote;
  }
}

enum OpportunityStatus {
  open,
  closed;

  static OpportunityStatus fromName(String? name) {
    return name == 'closed' ? OpportunityStatus.closed : OpportunityStatus.open;
  }
}

/// Mirrors an `opportunities/{id}` Firestore document.
///
/// [startupName] is stored redundantly here (instead of only on the
/// startup doc) so the discovery list can show it without an extra
/// Firestore read per card - a small, deliberate trade of a bit of
/// duplicated data for fewer reads.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.skillsRequired,
    required this.postedByUid,
    this.status = OpportunityStatus.open,
    this.createdAt,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final OpportunityCategory category;
  final OpportunityLocationType location;
  final List<String> skillsRequired;
  final String postedByUid;
  final OpportunityStatus status;
  final DateTime? createdAt;

  factory Opportunity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: OpportunityCategory.fromName(data['category'] as String?),
      location: OpportunityLocationType.fromName(data['location'] as String?),
      skillsRequired: List<String>.from(data['skillsRequired'] as List? ?? const []),
      postedByUid: data['postedByUid'] as String? ?? '',
      status: OpportunityStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
