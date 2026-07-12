import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_providers.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/home_shell.dart';
import 'features/onboarding/screens/profile_setup_screen.dart';
import 'features/onboarding/screens/role_selection_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Intern Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to show based on Firebase auth + onboarding state.
///
/// Both [authStateChangesProvider] and [currentAppUserProvider] are
/// StreamProviders, so every time Firebase Auth or the user's Firestore
/// document changes, this widget rebuilds and picks a new screen
/// automatically — no manual navigation calls needed anywhere else in
/// the auth/onboarding flow.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      error: (error, _) => _ErrorScreen(message: '$error'),
      data: (user) {
        if (user == null) return const LoginScreen();
        return const _OnboardingGate();
      },
    );
  }
}

class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserState = ref.watch(currentAppUserProvider);

    return appUserState.when(
      loading: () => const SplashScreen(),
      error: (error, _) => _ErrorScreen(message: '$error'),
      data: (appUser) {
        if (appUser == null) return const SplashScreen();
        if (appUser.role == null) return RoleSelectionScreen(uid: appUser.uid);
        if (!appUser.onboardingComplete) {
          return ProfileSetupScreen(uid: appUser.uid, role: appUser.role!);
        }
        return HomeShell(appUser: appUser);
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Something went wrong:\n$message', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
