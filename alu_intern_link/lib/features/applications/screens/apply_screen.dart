import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/app_user.dart';
import '../../opportunities/opportunity.dart';
import '../application_providers.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key, required this.opportunity, required this.appUser});

  final Opportunity opportunity;
  final AppUser appUser;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverNoteController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await ref.read(applicationRepositoryProvider).apply(
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupId: widget.opportunity.startupId,
      startupName: widget.opportunity.startupName,
      studentUid: widget.appUser.uid,
      studentName: widget.appUser.fullName ?? '',
      studentEmail: widget.appUser.email,
      coverNote: _coverNoteController.text.trim(),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply to ${widget.opportunity.title}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Tell ${widget.opportunity.startupName} why you would be a good fit.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _coverNoteController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Cover note',
                    hintText: 'Your relevant experience, availability, why you\'re interested…',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 20) {
                      return 'Please write at least a couple of sentences.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
