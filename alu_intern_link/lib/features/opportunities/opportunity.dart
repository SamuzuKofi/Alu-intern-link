import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show IconData, Icons;

enum OpportunityCategory {
  softwareDevelopment('Software Development', Icons.code_rounded),
  design('Design', Icons.palette_rounded),
  marketing('Marketing', Icons.campaign_rounded),
  operations('Operations', Icons.settings_rounded),
  research('Research', Icons.science_rounded),
  businessAnalysis('Business Analysis', Icons.bar_chart_rounded),
  contentCreation('Content Creation', Icons.edit_note_rounded),
  communityManagement('Community Management', Icons.groups_rounded);

  const OpportunityCategory(this.label, this.icon);
  final String label;
  final IconData icon;

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
    this.removedByAdmin = false,
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
  // Set by an admin to pull a posting off the platform regardless of what
  // the founder wants - separate from [status] so the founder's own
  // open/close toggle can't quietly undo an admin's moderation decision.
  final bool removedByAdmin;
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
      removedByAdmin: data['removedByAdmin'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
