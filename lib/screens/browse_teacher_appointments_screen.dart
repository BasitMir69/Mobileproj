import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:campus_wave/theme/theme_provider.dart';

class BrowseTeacherAppointmentsScreen extends StatefulWidget {
  const BrowseTeacherAppointmentsScreen({super.key});

  @override
  State<BrowseTeacherAppointmentsScreen> createState() =>
      _BrowseTeacherAppointmentsScreenState();
}

class _BrowseTeacherAppointmentsScreenState
    extends State<BrowseTeacherAppointmentsScreen> {
  final _auth = FirebaseAuth.instance;
  late String _studentId;

  String? _selectedCampus;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _studentId = _auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Teacher Appointments'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: tp.backgroundGradient),
        child: Column(
          children: [
            // Filters
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCampus,
                      decoration: InputDecoration(
                        labelText: 'Campus',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: tp.inputFillColor,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Campuses'),
                        ),
                        DropdownMenuItem(
                          value: 'LGS Gulberg Campus 1',
                          child: Text('LGS Gulberg Campus 1'),
                        ),
                        DropdownMenuItem(
                          value: 'LGS Gulberg Campus 2',
                          child: Text('LGS Gulberg Campus 2'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCampus = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: tp.inputFillColor,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Departments'),
                        ),
                        DropdownMenuItem(
                          value: 'Biology',
                          child: Text('Biology'),
                        ),
                        DropdownMenuItem(
                          value: 'Mathematics',
                          child: Text('Mathematics'),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Chemistry',
                          child: Text('Chemistry'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDepartment = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Appointments List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirestoreService.streamAllTeacherAppointments(
                  campus: _selectedCampus,
                  department: _selectedDepartment,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: tp.secondaryTextColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments available',
                            style: TextStyle(
                              color: tp.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for available slots',
                            style: TextStyle(color: tp.secondaryTextColor),
                          ),
                        ],
                      ),
                    );
                  }

                  final appointments = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      return _AppointmentCard(
                        appointment: appt,
                        studentId: _studentId,
                        onBooked: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('✅ Appointment booked successfully'),
                            ),
                          );
                        },
                      );
                    },
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

/// Reusable appointment card for browsing
class _AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final String studentId;
  final VoidCallback onBooked;

  const _AppointmentCard({
    required this.appointment,
    required this.studentId,
    required this.onBooked,
  });

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  late bool _isBooked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
  }

  Future<void> _checkBookingStatus() async {
    final isBooked = await FirestoreService.isStudentBookedTeacherAppointment(
      widget.appointment['id'],
      widget.studentId,
    );
    if (mounted) {
      setState(() => _isBooked = isBooked);
    }
  }

  Future<void> _toggleBooking() async {
    setState(() => _isLoading = true);

    try {
      if (_isBooked) {
        await FirestoreService.cancelTeacherAppointmentBooking(
          widget.appointment['id'],
          widget.studentId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Booking cancelled')),
        );
      } else {
        await FirestoreService.bookTeacherAppointment(
          widget.appointment['id'],
          widget.studentId,
        );
        widget.onBooked();
      }

      if (mounted) {
        setState(() => _isBooked = !_isBooked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher name and subject
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointment['teacherName'] ?? 'Unknown',
                          style: TextStyle(
                            color: tp.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.appointment['subject'] ?? '',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isBooked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Booked',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Department and campus
              Row(
                children: [
                  Icon(Icons.business,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    widget.appointment['department'] ?? '',
                    style: TextStyle(
                      color: tp.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_city,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.appointment['campus'] ?? '',
                      style: TextStyle(
                        color: tp.secondaryTextColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date, time, location
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.appointment['dayOfWeek']} • ${widget.appointment['timeSlot']}',
                    style: TextStyle(
                      color: tp.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.room, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.appointment['location'] ?? '',
                      style: TextStyle(
                        color: tp.secondaryTextColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Description
              if (widget.appointment['description'] != null &&
                  widget.appointment['description'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.appointment['description'],
                    style: TextStyle(
                      color: tp.secondaryTextColor,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _toggleBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isBooked ? Colors.grey : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          _isBooked ? 'Cancel Booking' : 'Book Appointment',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
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
