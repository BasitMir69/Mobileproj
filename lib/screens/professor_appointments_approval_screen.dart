import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfessorAppointmentsApprovalScreen extends StatelessWidget {
  const ProfessorAppointmentsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final q = FirebaseFirestore.instance
        .collection('appointmentID')
        .where('professorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Approvals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No appointments'));
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student: ${data['studentName'] ?? '-'}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Time: ${data['timeSlot'] ?? '-'}'),
                      Text('Subject: ${data['subject'] ?? '-'}'),
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
                      )
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
        .collection('appointmentID')
        .doc(id)
        .update({'status': status});
  }
}
