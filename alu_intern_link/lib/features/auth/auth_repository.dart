import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

/// Thin wrapper around FirebaseAuth + the `users` collection.
///
/// Kept deliberately free of Riverpod so it can be unit-tested with fake
/// FirebaseAuth/Firestore instances without spinning up the widget tree.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> watchAppUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final appUser = AppUser(uid: uid, email: email);
    await _users.doc(uid).set(appUser.toInitialFirestore());
  }

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> setRole(String uid, UserRole role) {
    return _users.doc(uid).update({'role': role.name});
  }

  Future<void> completeProfile({
    required String uid,
    required String fullName,
    String? bio,
    List<String> skills = const [],
  }) {
    return _users.doc(uid).update({
      'fullName': fullName,
      'bio': bio,
      'skills': skills,
      'onboardingComplete': true,
    });
  }
}
