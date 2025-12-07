import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_wave/data/campuses.dart';
import 'package:campus_wave/data/admission_form.dart';
import 'package:campus_wave/data/admission_form_db.dart';
import 'package:campus_wave/services/email_submission_service.dart';

class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentName = TextEditingController();
  final _parentEmail = TextEditingController();
  final _phone = TextEditingController();
  final _childName = TextEditingController();
  DateTime? _childDob;
  String? _grade;
  String? _campus;
  final _notes = TextEditingController();
  bool _saving = false;
  String? _gender;
  String? _documentPath;
  final _picker = ImagePicker();

  final _grades = const [
    'Playgroup',
    'Nursery',
    'Prep',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'O Levels',
    'A Levels',
  ];

  @override
  void dispose() {
    _parentName.dispose();
    _parentEmail.dispose();
    _phone.dispose();
    _childName.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 6, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _childDob ?? initial,
      firstDate: DateTime(2005),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) setState(() => _childDob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final sampleTestDate = DateTime.now().add(const Duration(days: 7));
      final form = AdmissionForm(
        parentName: _parentName.text.trim(),
        parentEmail: _parentEmail.text.trim(),
        phone: _phone.text.trim(),
        childName: _childName.text.trim(),
        childDob: (_childDob ?? DateTime(2018, 1, 1)).toIso8601String(),
        gradeApplying: _grade ?? 'Grade 1',
        campus: _campus ?? campuses.first.name,
        notes: _notes.text.trim(),
        gender: _gender!,
        documentPath: _documentPath,
        status: 'pending',
        testDate: sampleTestDate.toIso8601String(),
      );
      await AdmissionFormDb.instance.insert(form);
      await _sendEmail(form);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved offline. View in Saved Forms.')),
      );
      context.go('/admissions/saved');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendEmail(AdmissionForm form) async {
    try {
      await EmailSubmissionService.send(form);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email send failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusNames = campuses.map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission Form'),
        actions: [
          IconButton(
            tooltip: 'Saved Forms',
            icon: const Icon(Icons.folder_open),
            onPressed: () => context.push('/admissions/saved'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Parent Information',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _parentName,
                        decoration:
                            const InputDecoration(labelText: 'Full Name*'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _parentEmail,
                        decoration: const InputDecoration(labelText: 'Email*'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Valid email required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        decoration: const InputDecoration(labelText: 'Phone*'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().length < 7)
                            ? 'Valid phone required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Child Information',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _childName,
                        decoration:
                            const InputDecoration(labelText: 'Child Name*'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(labelText: 'Gender*'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'Female', child: Text('Female')),
                          DropdownMenuItem(
                              value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Date of Birth*'),
                              child: InkWell(
                                onTap: _pickDob,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text(_childDob == null
                                      ? 'Tap to pick'
                                      : _childDob!
                                          .toLocal()
                                          .toString()
                                          .split(' ')
                                          .first),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _grade,
                              decoration: const InputDecoration(
                                  labelText: 'Grade Applying*'),
                              items: _grades
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _grade = v),
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _campus,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Campus*'),
                        items: campusNames
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _campus = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _DocumentPicker(
                        path: _documentPath,
                        onPick: () async {
                          final picked = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (picked != null) {
                            setState(() => _documentPath = picked.path);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            hintText: 'Allergies, schedule preferences, etc.'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Submit',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(
                        'We will email your admission request (with CNIC/B-Form image) to the admissions office. You will see status updates in Saved Forms.',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.send_rounded),
                          label:
                              Text(_saving ? 'Submitting…' : 'Submit & Email'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/admissions/saved'),
                        icon: const Icon(Icons.folder),
                        label: const Text('View Saved Forms'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  final String? path;
  final VoidCallback onPick;

  const _DocumentPicker({required this.path, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.badge_outlined),
          title: const Text('CNIC / B-Form Image'),
          subtitle:
              Text(path == null ? 'Attach a clear photo' : 'Image attached'),
          trailing: TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload),
            label: Text(path == null ? 'Upload' : 'Replace'),
          ),
        ),
        if (path != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path!),
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}

class SavedAdmissionFormsScreen extends StatefulWidget {
  const SavedAdmissionFormsScreen({super.key});

  @override
  State<SavedAdmissionFormsScreen> createState() =>
      _SavedAdmissionFormsScreenState();
}

class _SavedAdmissionFormsScreenState extends State<SavedAdmissionFormsScreen> {
  bool _loading = true;
  List<AdmissionForm> _forms = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AdmissionFormDb.instance.all();
    setState(() {
      _forms = list;
      _loading = false;
    });
  }

  Future<void> _delete(int id) async {
    await AdmissionFormDb.instance.delete(id);
    await _load();
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear All?'),
            content:
                const Text('Remove all saved admission forms from device?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Clear')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await AdmissionFormDb.instance.clear();
    await _load();
  }

  Future<void> _updateStatus(AdmissionForm form, String status) async {
    String? testDate = form.testDate;
    if (status == 'approved') {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now.add(const Duration(days: 7)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 90)),
      );
      if (picked == null) return;
      testDate = picked.toIso8601String();
    } else {
      testDate = null;
    }
    await AdmissionFormDb.instance
        .updateStatus(form.id!, status, testDate: testDate);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to ${status.toUpperCase()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Admission Forms'),
        actions: [
          IconButton(
            tooltip: 'New Form',
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admissions/new'),
          ),
          IconButton(
            tooltip: 'Clear All',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forms.isEmpty
              ? const Center(child: Text('No saved forms yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _forms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final f = _forms[i];
                    final status = f.status;
                    final testDate = f.testDate == null
                        ? null
                        : DateTime.tryParse(f.testDate!);
                    return Card(
                      child: ListTile(
                        title: Text('${f.childName} • ${f.gradeApplying}'),
                        subtitle: Text(
                            'Campus: ${f.campus}\nParent: ${f.parentName} • ${f.phone}\nStatus: ${status.toUpperCase()}${testDate != null ? ' • Test: ${testDate.toLocal().toString().split(' ').first}' : ''}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              tooltip: 'Change status',
                              onSelected: (v) => _updateStatus(f, v),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                    value: 'pending', child: Text('Pending')),
                                PopupMenuItem(
                                    value: 'approved', child: Text('Approved')),
                                PopupMenuItem(
                                    value: 'rejected', child: Text('Rejected')),
                              ],
                              child: Chip(
                                label: Text(status.toUpperCase()),
                                backgroundColor: status == 'approved'
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : status == 'rejected'
                                        ? Colors.red.withValues(alpha: 0.15)
                                        : Colors.orange.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: status == 'approved'
                                      ? Colors.green.shade800
                                      : status == 'rejected'
                                          ? Colors.red.shade800
                                          : Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(f.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
