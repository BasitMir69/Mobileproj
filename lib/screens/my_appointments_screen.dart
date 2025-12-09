import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Appointments')),
        body: const Center(child: Text('Please sign in to view appointments')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.streamUserAppointments(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments booked yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final appt = appointments[i];
              final status = appt['status'] ?? 'pending';
              final professorId = appt['ProffessorID'] ?? 'Unknown';
              final slot = appt['requestedSlot'] ?? '-';
              final location = appt['location'] ?? '-';

              Color statusColor;
              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                child: ListTile(
                  leading: Icon(
                    status == 'approved'
                        ? Icons.check_circle
                        : status == 'rejected'
                            ? Icons.cancel
                            : Icons.schedule,
                    color: statusColor,
                  ),
                  title: _ProfessorName(professorId: professorId),
                  subtitle: Text(
                    'Time: $slot\nLocation: $location\nStatus: ${status.toUpperCase()}',
                  ),
                  isThreeLine: true,
                  trailing: status == 'pending'
                      ? TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancel Appointment'),
                                content: const Text(
                                    'Are you sure you want to cancel this appointment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Yes, Cancel'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await FirestoreService.deleteAppointment(
                                    appt['id'] as String);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Appointment cancelled')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.redAccent)),
                        )
                      : Chip(
                          label: Text(status.toUpperCase()),
                          backgroundColor: statusColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfessorName extends StatelessWidget {
  final String professorId;
  const _ProfessorName({required this.professorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService.getProfessorById(professorId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Text('Professor: …');
        }
        final data = snap.data;
        final name = data?['name'] as String?;

        // Fallback: known demo id mapping
        final displayName = name ??
            (professorId == 'demo_professor' ? 'Dr Ayesha Khan' : professorId);

        return Text('Professor: $displayName');
      },
    );
  }
}
