import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'startup.dart';
import 'startup_repository.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository(firestore: ref.watch(firestoreProvider));
});

/// `.family` lets us pass in which owner's startups we want to watch — the
/// same provider is reused for any uid instead of writing one provider per
/// user. `.autoDispose` clears its state once nobody's watching it (e.g.
/// after sign-out), so signing back in starts a fresh stream instead of
/// replaying whatever error the last session ended on.
final myStartupsProvider = StreamProvider.autoDispose.family<List<Startup>, String>((ref, ownerUid) {
  return ref.watch(startupRepositoryProvider).watchStartupsForOwner(ownerUid);
});

final startupByIdProvider = StreamProvider.autoDispose.family<Startup?, String>((ref, startupId) {
  return ref.watch(startupRepositoryProvider).watchStartupById(startupId);
});

final pendingStartupsProvider = StreamProvider.autoDispose<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchPendingStartups();
});
