import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';

class ProfessorAppointmentsScreen extends StatefulWidget {
  const ProfessorAppointmentsScreen({super.key});

  @override
  State<ProfessorAppointmentsScreen> createState() =>
      _ProfessorAppointmentsScreenState();
}

class _ProfessorAppointmentsScreenState
    extends State<ProfessorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _professorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfessorId();
  }

  Future<void> _loadProfessorId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get professor document by user ID
    final prof = await FirestoreService.getProfessorByUserId(user.uid);
    if (prof != null && mounted) {
      setState(() {
        _professorId = prof['id'];
      });
      return;
    }

    // Fallback: demo professor document
    final demo = await FirestoreService.getProfessorById('demo_professor');
    if (demo != null && mounted) {
      setState(() {
        _professorId = demo['id'];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_outlined)),
            Tab(text: 'Confirmed', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _professorId == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  professorId: _professorId!,
                  statusFilter: 'pending',
                  onAction: _handleAppointmentAction,
                ),
                _AppointmentList(
                  professorId: _professorId!,
                  statusFilter: 'confirmed',
                ),
                _AppointmentList(
                  professorId: _professorId!,
                  statusFilter: ['rejected', 'cancelled'],
                ),
              ],
            ),
    );
  }

  Future<void> _handleAppointmentAction(
    String appointmentId,
    String action,
  ) async {
    if (action == 'confirm') {
      await FirestoreService.updateAppointmentStatus(
          appointmentId, 'confirmed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment confirmed')),
      );
    } else if (action == 'reject') {
      // Show dialog for rejection notes
      final notes = await _showRejectDialog();
      if (notes == null) return;

      await FirestoreService.updateAppointmentStatus(
        appointmentId,
        'rejected',
        professorNotes: notes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rejected')),
      );
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Time slot no longer available',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final String professorId;
  final dynamic statusFilter; // String or List<String>
  final Future<void> Function(String appointmentId, String action)? onAction;

  const _AppointmentList({
    required this.professorId,
    required this.statusFilter,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.streamProfessorAppointments(professorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var appointments = snapshot.data ?? [];

        // Filter by status
        if (statusFilter is String) {
          appointments = appointments
              .where((apt) => apt['status'] == statusFilter)
              .toList();
        } else if (statusFilter is List<String>) {
          appointments = appointments
              .where((apt) => (statusFilter as List).contains(apt['status']))
              .toList();
        }

        if (appointments.isEmpty) {
          return const Center(
            child: Text(
              'No appointments',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index];
            return _AppointmentCard(
              appointment: apt,
              onAction: onAction,
            );
          },
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Future<void> Function(String appointmentId, String action)? onAction;

  const _AppointmentCard({
    required this.appointment,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = appointment['status'] ?? 'pending';
    final studentId = appointment['studentID'] ?? 'Unknown';
    final campus = appointment['campus'] ?? '';
    final location = appointment['location'] ?? '';
    final slot = appointment['requestedSlot'] ?? '';
    final notes = appointment['professorNotes'];
    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: FirestoreService.getUserProfile(studentId),
                    builder: (context, snapshot) {
                      final studentName = snapshot.data?['displayName'] ??
                          snapshot.data?['email'] ??
                          'Student ID: $studentId';
                      return Text(
                        studentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time, text: slot),
            _InfoRow(icon: Icons.location_on_outlined, text: location),
            _InfoRow(icon: Icons.school_outlined, text: campus),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_outlined,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notes,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isPending && onAction != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAction!(appointment['id'], 'reject'),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onAction!(appointment['id'], 'confirm'),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }
}
