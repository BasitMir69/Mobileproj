import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_wave/services/firestore_service.dart';

class AdminCampusInfoScreen extends StatefulWidget {
  const AdminCampusInfoScreen({super.key});

  @override
  State<AdminCampusInfoScreen> createState() => _AdminCampusInfoScreenState();
}

class _AdminCampusInfoScreenState extends State<AdminCampusInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCampusSlug = 'lgs-paragon';
  final _overviewController = TextEditingController();
  final _historyController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _overviewController.dispose();
    _historyController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await FirestoreService.updateCampusInfo(
        campusSlug: _selectedCampusSlug,
        overview: _overviewController.text.trim(),
        history: _historyController.text.trim(),
        about: _aboutController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campus info saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Campus Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Simple campus selector; could be improved
            Row(
              children: [
                const Text('Campus:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedCampusSlug,
                  items: const [
                    DropdownMenuItem(
                        value: 'lgs-paragon', child: Text('LGS Paragon')),
                    DropdownMenuItem(
                        value: 'lgs-johar-town', child: Text('LGS Johar Town')),
                    DropdownMenuItem(
                        value: 'lgs-ib-phase', child: Text('LGS IB Phase')),
                    DropdownMenuItem(
                        value: 'lgs-42b-gulberg',
                        child: Text('LGS 42B Gulberg III')),
                    DropdownMenuItem(value: 'lgs-1a1', child: Text('LGS 1A1')),
                    DropdownMenuItem(
                        value: 'lgs-gulberg-campus-2',
                        child: Text('LGS Gulberg Campus 2')),
                  ],
                  onChanged: (v) => setState(() => _selectedCampusSlug = v!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirestoreService.streamCampusInfo(_selectedCampusSlug),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  if (data != null) {
                    _overviewController.text = data['overview'] ?? '';
                    _historyController.text = data['history'] ?? '';
                    _aboutController.text = data['about'] ?? '';
                  }

                  return Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _overviewController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Overview',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _historyController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'History',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _aboutController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'About',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: const Icon(Icons.save),
                            label: Text(_saving ? 'Saving...' : 'Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
