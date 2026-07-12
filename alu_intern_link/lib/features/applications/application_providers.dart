import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'application.dart';
import 'application_repository.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(firestore: ref.watch(firestoreProvider));
});

/// The `(opportunityId, studentUid)` here is a Dart record - basically a
/// small bundle of two values used as the family's key, since this query
/// needs both pieces of information to know which application to watch.
final myApplicationForOpportunityProvider =
    StreamProvider.family<Application?, (String opportunityId, String studentUid)>((ref, key) {
      final (opportunityId, studentUid) = key;
      return ref.watch(applicationRepositoryProvider).watchApplicationFor(opportunityId, studentUid);
    });

final applicationsForStudentProvider = StreamProvider.family<List<Application>, String>((
  ref,
  studentUid,
) {
  return ref.watch(applicationRepositoryProvider).watchApplicationsForStudent(studentUid);
});

final applicationsForOpportunityProvider = StreamProvider.family<List<Application>, String>((
  ref,
  opportunityId,
) {
  return ref.watch(applicationRepositoryProvider).watchApplicationsForOpportunity(opportunityId);
});
