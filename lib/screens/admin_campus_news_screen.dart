import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';

class AdminCampusNewsScreen extends StatefulWidget {
  const AdminCampusNewsScreen({super.key});

  @override
  State<AdminCampusNewsScreen> createState() => _AdminCampusNewsScreenState();
}

class _AdminCampusNewsScreenState extends State<AdminCampusNewsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _campus = 'All Campuses';
  bool _published = false;
  String _filterCampus = 'All Campuses';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus News')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _campus,
                        items: const [
                          DropdownMenuItem(
                              value: 'All Campuses',
                              child: Text('All Campuses')),
                          DropdownMenuItem(
                              value: 'LGS 1A1', child: Text('LGS 1A1')),
                          DropdownMenuItem(
                              value: 'LGS 42 B-III Gulberg',
                              child: Text('LGS 42 B-III Gulberg')),
                          DropdownMenuItem(
                              value: 'LGS Gulberg Campus 2',
                              child: Text('LGS Gulberg Campus 2')),
                        ],
                        onChanged: (v) =>
                            setState(() => _campus = v ?? 'All Campuses'),
                        decoration: const InputDecoration(labelText: 'Campus'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _published,
                      onChanged: (v) => setState(() => _published = v),
                    ),
                    const Text('Published')
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Add News'),
                  onPressed: _addNews,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterCampus,
                    items: const [
                      DropdownMenuItem(
                          value: 'All Campuses', child: Text('All Campuses')),
                      DropdownMenuItem(
                          value: 'LGS 1A1', child: Text('LGS 1A1')),
                      DropdownMenuItem(
                          value: 'LGS 42 B-III Gulberg',
                          child: Text('LGS 42 B-III Gulberg')),
                      DropdownMenuItem(
                          value: 'LGS Gulberg Campus 2',
                          child: Text('LGS Gulberg Campus 2')),
                    ],
                    onChanged: (v) => setState(() {
                      _filterCampus = v ?? 'All Campuses';
                    }),
                    decoration:
                        const InputDecoration(labelText: 'Filter by campus'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Search title/content'),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.streamCampusNews(
                campus: _filterCampus == 'All Campuses' ? null : _filterCampus,
              ),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snap.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final title =
                        (data['title'] ?? '').toString().toLowerCase();
                    final content =
                        (data['content'] ?? '').toString().toLowerCase();
                    return title.contains(q) || content.contains(q);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No news yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(
                            '${data['campus']} • ${data['published'] == true ? 'Published' : 'Draft'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit and confirm',
                              onPressed: () => _openEditDialog(d.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  FirestoreService.deleteCampusNews(d.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _addNews() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'admin';
    await FirestoreService.createCampusNews(
      title: title,
      content: content,
      campus: _campus,
      authorId: uid,
      published: _published,
    );
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _campus = 'All Campuses';
      _published = false;
    });
  }

  Future<void> _openEditDialog(String id, Map<String, dynamic> data) async {
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final contentCtrl = TextEditingController(text: data['content'] ?? '');
    String campus = (data['campus'] ?? 'All Campuses') as String;
    bool published = (data['published'] == true);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit News'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: campus,
                      items: const [
                        DropdownMenuItem(
                            value: 'All Campuses', child: Text('All Campuses')),
                        DropdownMenuItem(
                            value: 'LGS 1A1', child: Text('LGS 1A1')),
                        DropdownMenuItem(
                            value: 'LGS 42 B-III Gulberg',
                            child: Text('LGS 42 B-III Gulberg')),
                        DropdownMenuItem(
                            value: 'LGS Gulberg Campus 2',
                            child: Text('LGS Gulberg Campus 2')),
                      ],
                      onChanged: (v) => setDialogState(() {
                        campus = v ?? 'All Campuses';
                      }),
                      decoration: const InputDecoration(labelText: 'Campus'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: published,
                      onChanged: (v) => setDialogState(() {
                        published = v;
                      }),
                      title: const Text('Published'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm Edit'),
                  onPressed: () async {
                    await FirestoreService.updateCampusNews(
                      id: id,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      campus: campus,
                      published: published,
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
