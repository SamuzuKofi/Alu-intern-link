import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'startup.dart';
import 'startup_repository.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository(firestore: ref.watch(firestoreProvider));
});

/// `.family` lets us pass in which owner's startup we want to watch — the
/// same provider is reused for any uid instead of writing one provider per
/// user.
final myStartupProvider = StreamProvider.family<Startup?, String>((ref, ownerUid) {
  return ref.watch(startupRepositoryProvider).watchStartupForOwner(ownerUid);
});

final pendingStartupsProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchPendingStartups();
});
