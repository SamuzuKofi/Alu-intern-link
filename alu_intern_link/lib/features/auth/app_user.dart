import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  startup;

  static UserRole? fromName(String? name) {
    if (name == null) return null;
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }
}

/// Mirrors the `users/{uid}` Firestore document.
///
/// A user is created (with [role] and [onboardingComplete] unset) the
/// moment they sign up, then progressively filled in through onboarding.
/// Splitting signup from onboarding lets the router gate navigation purely
/// on document state instead of tracking a separate client-side flow.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.fullName,
    this.role,
    this.bio,
    this.skills = const [],
    this.photoUrl,
    this.onboardingComplete = false,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? fullName;
  final UserRole? role;
  final String? bio;
  final List<String> skills;
  final String? photoUrl;
  final bool onboardingComplete;
  final DateTime? createdAt;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String?,
      role: UserRole.fromName(data['role'] as String?),
      bio: data['bio'] as String?,
      skills: List<String>.from(data['skills'] as List? ?? const []),
      photoUrl: data['photoUrl'] as String?,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toInitialFirestore() => {
    'email': email,
    'onboardingComplete': false,
    'createdAt': FieldValue.serverTimestamp(),
  };

  AppUser copyWith({
    String? fullName,
    UserRole? role,
    String? bio,
    List<String>? skills,
    String? photoUrl,
    bool? onboardingComplete,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
    );
  }
}
