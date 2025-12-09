import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';

class ProfessorAppointmentsApprovalScreen extends StatelessWidget {
  const ProfessorAppointmentsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService.getProfessorByUserId(uid),
      builder: (context, profSnap) {
        if (profSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final prof = profSnap.data;
        if (prof == null) {
          return const Scaffold(
            body: Center(child: Text('Professor profile not linked')),
          );
        }
        final professorId = prof['id'] as String;

        return Scaffold(
          appBar: AppBar(title: const Text('Appointment Approvals')),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService.streamProfessorAppointments(professorId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const Center(child: Text('No appointments'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final data = items[i];
                  final status = (data['status'] ?? 'pending') as String;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student: ${data['studentID'] ?? '-'}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Time: ${data['requestedSlot'] ?? '-'}'),
                          Text('Location: ${data['location'] ?? '-'}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(label: Text(status)),
                              const Spacer(),
                              TextButton.icon(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                label: const Text('Approve'),
                                onPressed: () => _setStatus(
                                    data['id'] as String, 'approved'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                label: const Text('Reject'),
                                onPressed: () => _setStatus(
                                    data['id'] as String, 'rejected'),
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
      },
    );
  }

  Future<void> _setStatus(String id, String status) async {
    await FirestoreService.updateAppointmentStatus(id, status);
  }
}
