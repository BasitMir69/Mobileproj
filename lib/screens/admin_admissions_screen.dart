import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class AdminAdmissionsScreen extends StatefulWidget {
  const AdminAdmissionsScreen({super.key});

  @override
  State<AdminAdmissionsScreen> createState() => _AdminAdmissionsScreenState();
}

class _AdminAdmissionsScreenState extends State<AdminAdmissionsScreen> {
  String? _filterStatus; // null = all

  @override
  Widget build(BuildContext context) {
    Query admissions = FirebaseFirestore.instance
        .collection('admission_submissions')
        .orderBy('createdAt', descending: true);
    if (_filterStatus != null) {
      admissions = admissions.where('status', isEqualTo: _filterStatus);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions Management'),
        actions: [
          PopupMenuButton<String?>(
            initialValue: _filterStatus,
            onSelected: (val) => setState(() => _filterStatus = val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'approved', child: Text('Approved')),
              PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: admissions.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No submissions'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final status = (data['status'] ?? 'pending') as String;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['childName'] ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Parent: ${data['parentName'] ?? '-'}'),
                      Text('Email: ${data['parentEmail'] ?? '-'}'),
                      Text('Campus: ${data['campus'] ?? '-'}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(label: Text(status)),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            label: const Text('Approve'),
                            onPressed: () => _setStatus(d.id, 'approved'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text('Reject'),
                            onPressed: () => _setStatus(d.id, 'rejected'),
                          ),
                        ],
                      ),
                      if (data['imageBase64'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.memory(
                            _decodeBase64(data['imageBase64'] as String),
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('admission_submissions')
        .doc(id)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Uint8List _decodeBase64(String s) {
    return base64.decode(s);
  }
}
