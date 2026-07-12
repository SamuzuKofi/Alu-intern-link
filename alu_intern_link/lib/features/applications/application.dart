import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending('Pending'),
  reviewed('Reviewed'),
  accepted('Accepted'),
  rejected('Rejected');

  const ApplicationStatus(this.label);
  final String label;

  static ApplicationStatus fromName(String? name) {
    for (final status in ApplicationStatus.values) {
      if (status.name == name) return status;
    }
    return ApplicationStatus.pending;
  }
}

/// Mirrors an `applications/{id}` Firestore document.
///
/// Like [Opportunity], this stores a few denormalized fields
/// (opportunityTitle, startupName, studentName) so lists can display
/// nicely without extra reads for every card.
class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentUid,
    required this.studentName,
    required this.studentEmail,
    required this.coverNote,
    this.status = ApplicationStatus.pending,
    this.createdAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentUid;
  final String studentName;
  final String studentEmail;
  final String coverNote;
  final ApplicationStatus status;
  final DateTime? createdAt;

  factory Application.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentUid: data['studentUid'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      studentEmail: data['studentEmail'] as String? ?? '',
      coverNote: data['coverNote'] as String? ?? '',
      status: ApplicationStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
