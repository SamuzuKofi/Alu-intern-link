import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'opportunity.dart';
import 'opportunity_repository.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(firestore: ref.watch(firestoreProvider));
});

final openOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpenOpportunities();
});

final opportunitiesForStartupProvider = StreamProvider.family<List<Opportunity>, String>((
  ref,
  startupId,
) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunitiesForStartup(startupId);
});
