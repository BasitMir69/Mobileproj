import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/services/firestore_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String _role = 'student';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snap.data() ?? {};
      final r = (data['role'] as String?) ?? 'student';
      if (mounted) setState(() => _role = r);
    } catch (_) {}
  }

  Future<void> _cancelAppointment(String appointmentId, String status) async {
    // Don't allow cancelling if already confirmed or rejected
    if (status == 'confirmed' || status == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Cannot cancel ${status} appointments. Contact professor.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cancel booking?'),
            content: const Text(
                'This will notify the professor that you cancelled this appointment.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Yes, cancel')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await FirestoreService.updateAppointmentStatus(
          appointmentId, 'cancelled');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Appointment cancelled. Professor notified.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete appointment?'),
            content: const Text(
                'This will permanently remove this appointment from your history.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await FirestoreService.deleteAppointment(appointmentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointments')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please log in to view and manage your bookings.'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      floatingActionButton: _role == 'professor'
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.pushNamed('professors'),
              icon: const Icon(Icons.person_search),
              label: const Text('Find Professors'),
            ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.streamUserAppointments(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No appointments yet. Book with a professor!'),
                  const SizedBox(height: 12),
                  if (_role != 'professor')
                    ElevatedButton.icon(
                      onPressed: () => context.pushNamed('professors'),
                      icon: const Icon(Icons.person_search),
                      label: const Text('Find Professors'),
                    ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final appt = appointments[i];
              final profId = appt['ProffessorID'] ?? '';
              final campus = appt['campus'] ?? '';
              final location = appt['location'] ?? '';
              final slot = appt['requestedSlot'] ?? '';
              final appointmentId = appt['id'] ?? '';
              final status = (appt['status'] ?? 'pending') as String;
              final professorNotes = appt['professorNotes'] as String?;

              // Status badge color and icon
              Color statusColor;
              IconData statusIcon;
              String statusLabel;
              switch (status) {
                case 'confirmed':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusLabel = 'Confirmed';
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusLabel = 'Rejected';
                  break;
                case 'cancelled':
                  statusColor = Colors.orange;
                  statusIcon = Icons.event_busy;
                  statusLabel = 'Cancelled';
                  break;
                default:
                  statusColor = Colors.blue;
                  statusIcon = Icons.pending;
                  statusLabel = 'Pending';
              }

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.2),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Professor: $profId',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(statusIcon,
                                        size: 16, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusLabel,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                          icon: Icons.location_on,
                          label: 'Campus',
                          value: campus),
                      _InfoRow(
                          icon: Icons.room, label: 'Location', value: location),
                      _InfoRow(
                          icon: Icons.schedule, label: 'Time', value: slot),
                      if (professorNotes != null &&
                          professorNotes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note,
                                  size: 18, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Professor\'s note: $professorNotes',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'pending') ...[
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _cancelAppointment(appointmentId, status),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ] else if (status == 'cancelled' ||
                              status == 'rejected') ...[
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _deleteAppointment(appointmentId),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => context.pushNamed('professors'),
                            icon: const Icon(Icons.person_search, size: 18),
                            label: const Text('Find Professors'),
                          ),
                        ],
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
