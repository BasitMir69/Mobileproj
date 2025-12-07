import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:campus_wave/theme/theme_provider.dart';

class TeacherAppointmentManagementScreen extends StatefulWidget {
  const TeacherAppointmentManagementScreen({super.key});

  @override
  State<TeacherAppointmentManagementScreen> createState() =>
      _TeacherAppointmentManagementScreenState();
}

class _TeacherAppointmentManagementScreenState
    extends State<TeacherAppointmentManagementScreen> {
  final _auth = FirebaseAuth.instance;
  late String _teacherId;
  late String _teacherName;

  @override
  void initState() {
    super.initState();
    _teacherId = _auth.currentUser?.uid ?? '';
    _teacherName = _auth.currentUser?.displayName ?? 'Teacher';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Appointments'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: tp.backgroundGradient),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Tab Bar
              TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: tp.secondaryTextColor,
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'My Appointments'),
                  Tab(text: 'Add New'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: List of teacher's appointments
                    _buildAppointmentsList(),
                    // Tab 2: Add new appointment form
                    _buildAddAppointmentForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the list of appointments created by this teacher
  Widget _buildAppointmentsList() {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.streamTeacherAppointments(_teacherId),
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
                  Icons.calendar_month,
                  size: 80,
                  color: tp.secondaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments yet',
                  style: TextStyle(
                    color: tp.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first appointment slot',
                  style: TextStyle(color: tp.secondaryTextColor),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appt = appointments[index];
            final bookedCount =
                (appt['bookedByStudents'] as List<dynamic>).length;

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
                      // Title and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              appt['subject'] ?? 'Appointment',
                              style: TextStyle(
                                color: tp.primaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appt['status'] == 'available'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appt['status'] ?? 'available',
                              style: TextStyle(
                                color: appt['status'] == 'available'
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date and Time
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${appt['dayOfWeek']} • ${appt['timeSlot']}',
                            style: TextStyle(
                              color: tp.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            appt['location'] ?? '',
                            style: TextStyle(
                              color: tp.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      if (appt['description'] != null &&
                          appt['description'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            appt['description'],
                            style: TextStyle(
                              color: tp.secondaryTextColor,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Stats and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Booked count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$bookedCount Student${bookedCount != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _editAppointment(appt),
                                icon: const Icon(Icons.edit),
                                iconSize: 18,
                                color: theme.colorScheme.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 30),
                              ),
                              IconButton(
                                onPressed: () => _deleteAppointment(appt['id']),
                                icon: const Icon(Icons.delete),
                                iconSize: 18,
                                color: Colors.red,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build the form to add new appointment
  Widget _buildAddAppointmentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _AddAppointmentForm(
        teacherId: _teacherId,
        teacherName: _teacherName,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Appointment created successfully')),
          );
        },
      ),
    );
  }

  Future<void> _editAppointment(Map<String, dynamic> appt) async {
    // Show edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: SingleChildScrollView(
          child: _EditAppointmentForm(appointment: appt),
        ),
      ),
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.deleteTeacherAppointment(appointmentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Appointment deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

/// Form to add a new appointment
class _AddAppointmentForm extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final VoidCallback onSuccess;

  const _AddAppointmentForm({
    required this.teacherId,
    required this.teacherName,
    required this.onSuccess,
  });

  @override
  State<_AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<_AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _departmentController;
  late TextEditingController _campusController;
  late TextEditingController _timeSlotController;
  late TextEditingController _dayOfWeekController;
  late TextEditingController _durationController;

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _departmentController = TextEditingController();
    _campusController = TextEditingController();
    _timeSlotController = TextEditingController();
    _dayOfWeekController = TextEditingController();
    _durationController = TextEditingController(text: '60');
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _campusController.dispose();
    _timeSlotController.dispose();
    _dayOfWeekController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.createTeacherAppointment(
        teacherId: widget.teacherId,
        teacherName: widget.teacherName,
        department: _departmentController.text.trim(),
        campus: _campusController.text.trim(),
        location: _locationController.text.trim(),
        appointmentDateTime: _selectedDate!,
        dayOfWeek: _dayOfWeekController.text.trim(),
        timeSlot: _timeSlotController.text.trim(),
        durationMinutes: int.parse(_durationController.text),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        widget.onSuccess();
        _clearForm();
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

  void _clearForm() {
    _subjectController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _departmentController.clear();
    _campusController.clear();
    _timeSlotController.clear();
    _dayOfWeekController.clear();
    _durationController.text = '60';
    _selectedDate = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subject
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject/Topic',
              hintText: 'e.g., Biology Lab Session',
              prefixIcon: const Icon(Icons.subject),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Subject is required' : null,
          ),
          const SizedBox(height: 12),
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Additional details about the appointment',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          // Department
          TextFormField(
            controller: _departmentController,
            decoration: InputDecoration(
              labelText: 'Department',
              hintText: 'e.g., Biology, Mathematics',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Department is required' : null,
          ),
          const SizedBox(height: 12),
          // Campus
          TextFormField(
            controller: _campusController,
            decoration: InputDecoration(
              labelText: 'Campus',
              hintText: 'e.g., LGS Gulberg Campus 2',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Campus is required' : null,
          ),
          const SizedBox(height: 12),
          // Location/Room
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Room/Location',
              hintText: 'e.g., Lab 101, Office 3B',
              prefixIcon: const Icon(Icons.room),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Location is required' : null,
          ),
          const SizedBox(height: 12),
          // Date Picker
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      color: _selectedDate == null
                          ? tp.secondaryTextColor
                          : tp.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Day of Week
          TextFormField(
            controller: _dayOfWeekController,
            decoration: InputDecoration(
              labelText: 'Day of Week',
              hintText: 'e.g., Monday, Tuesday',
              prefixIcon: const Icon(Icons.calendar_month),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Day of week is required' : null,
          ),
          const SizedBox(height: 12),
          // Time Slot
          TextFormField(
            controller: _timeSlotController,
            decoration: InputDecoration(
              labelText: 'Time Slot',
              hintText: 'e.g., 10:00 AM - 11:00 AM',
              prefixIcon: const Icon(Icons.schedule),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Time slot is required' : null,
          ),
          const SizedBox(height: 12),
          // Duration
          TextFormField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: 'Duration (minutes)',
              hintText: '60',
              prefixIcon: const Icon(Icons.timer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) return 'Duration is required';
              if (int.tryParse(value!) == null) return 'Enter a valid number';
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Text('Create Appointment'),
          ),
        ],
      ),
    );
  }
}

/// Form to edit an existing appointment
class _EditAppointmentForm extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const _EditAppointmentForm({required this.appointment});

  @override
  State<_EditAppointmentForm> createState() => _EditAppointmentFormState();
}

class _EditAppointmentFormState extends State<_EditAppointmentForm> {
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _timeSlotController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController =
        TextEditingController(text: widget.appointment['subject']);
    _descriptionController =
        TextEditingController(text: widget.appointment['description']);
    _locationController =
        TextEditingController(text: widget.appointment['location']);
    _timeSlotController =
        TextEditingController(text: widget.appointment['timeSlot']);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeSlotController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    setState(() => _isLoading = true);

    try {
      await FirestoreService.updateTeacherAppointment(
        widget.appointment['id'],
        {
          'subject': _subjectController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim(),
          'timeSlot': _timeSlotController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Appointment updated')),
        );
        Navigator.pop(context);
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(labelText: 'Subject'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Location'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _timeSlotController,
          decoration: const InputDecoration(labelText: 'Time Slot'),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitEdit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
