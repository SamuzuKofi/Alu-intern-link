import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'opportunity.dart';
import 'opportunity_repository.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(firestore: ref.watch(firestoreProvider));
});

// autoDispose matters here: none of these providers watch the signed-in
// user, so without it they'd keep running (and caching whatever error
// they last hit) for the entire app session, even across sign-out/sign-in.
// autoDispose throws each one away once its screen is no longer on
// screen, so the next time it's needed it starts a completely fresh
// Firestore stream instead of replaying a stale error.
final openOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpenOpportunities();
});

final opportunitiesForStartupProvider = StreamProvider.autoDispose.family<List<Opportunity>, String>((
  ref,
  startupId,
) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunitiesForStartup(startupId);
});

final opportunityByIdProvider = StreamProvider.autoDispose.family<Opportunity?, String>((
  ref,
  opportunityId,
) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunityById(opportunityId);
});

final allOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchAllOpportunities();
});
