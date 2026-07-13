import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../startup_providers.dart';

/// Registers a new startup for [ownerUid]. Reachable both during
/// onboarding-adjacent first use and any time afterward from "Add another
/// startup" - a founder isn't limited to registering one.
class CreateStartupScreen extends ConsumerStatefulWidget {
  const CreateStartupScreen({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  ConsumerState<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends ConsumerState<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await ref.read(startupRepositoryProvider).createStartup(
      ownerUid: widget.ownerUid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      industry: _industryController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a startup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('An ALU admin will review this before you can post opportunities.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Startup name'),
                  validator: (v) => Validators.required(v, label: 'Startup name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _industryController,
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    hintText: 'e.g. FinTech, EdTech, Agriculture',
                  ),
                  validator: (v) => Validators.required(v, label: 'Industry'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What does your startup do?',
                  ),
                  validator: (v) => Validators.required(v, label: 'Description'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (optional)',
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit for review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
