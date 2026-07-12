import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';

/// First onboarding step: are you here to find an opportunity, or to post
/// one on behalf of a startup? This choice decides what the rest of the
/// app looks like for this account.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key, required this.uid});

  final String uid;

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _isSaving = false;

  Future<void> _chooseRole(UserRole role) async {
    setState(() => _isSaving = true);
    await ref.read(authRepositoryProvider).setRole(widget.uid, role);
    // AuthGate re-reads the user document and moves us to the next
    // onboarding step, so we don't need to navigate manually.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Welcome to ALU Intern Link', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Tell us why you are here so we can set up your account.'),
              const SizedBox(height: 32),
              Expanded(
                child: _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _RoleCard(
                            icon: Icons.search_rounded,
                            title: "I'm a student",
                            subtitle: 'Looking for internships and opportunities',
                            onTap: () => _chooseRole(UserRole.student),
                          ),
                          const SizedBox(height: 16),
                          _RoleCard(
                            icon: Icons.rocket_launch_rounded,
                            title: 'I run a startup',
                            subtitle: 'Looking to post opportunities and find talent',
                            onTap: () => _chooseRole(UserRole.startup),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
