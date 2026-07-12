import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';

/// Second onboarding step: basic profile details. Once this is saved,
/// `onboardingComplete` flips to true and AuthGate sends the user into
/// the main app.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, required this.uid, required this.role});

  final String uid;
  final UserRole role;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await ref.read(authRepositoryProvider).completeProfile(
      uid: widget.uid,
      fullName: _fullNameController.text.trim(),
      bio: _bioController.text.trim(),
      skills: skills,
    );
    // No manual navigation: once onboardingComplete is true, AuthGate
    // takes us to the home shell on its own.
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => Validators.required(v, label: 'Full name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isStudent ? 'Short bio' : 'About you',
                    hintText: isStudent
                        ? 'What are you studying? What are you looking for?'
                        : 'Your role at the startup',
                  ),
                ),
                if (isStudent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Skills',
                      hintText: 'e.g. Flutter, UI Design, Marketing',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Finish'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
