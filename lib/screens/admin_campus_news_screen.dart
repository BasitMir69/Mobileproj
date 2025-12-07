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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.streamCampusNews(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
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
                              onPressed: () => _editNews(d.id, data),
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

  Future<void> _editNews(String id, Map<String, dynamic> data) async {
    // Simple toggle published for demo; could open a dialog for full edit
    final newPublished = !(data['published'] == true);
    await FirestoreService.updateCampusNews(id: id, published: newPublished);
  }
}
