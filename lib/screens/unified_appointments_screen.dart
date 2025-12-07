import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:campus_wave/screens/appointments_screen.dart';
import 'package:campus_wave/screens/professor_appointments_screen.dart';

/// Unified appointments screen that shows different content based on user role
class UnifiedAppointmentsScreen extends StatefulWidget {
  const UnifiedAppointmentsScreen({super.key});

  @override
  State<UnifiedAppointmentsScreen> createState() =>
      _UnifiedAppointmentsScreenState();
}

class _UnifiedAppointmentsScreenState extends State<UnifiedAppointmentsScreen> {
  final _auth = FirebaseAuth.instance;
  String? _userRole;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userProfile = await FirestoreService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userRole = userProfile?['role'] ?? 'student';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userRole = 'student'; // Default to student on error
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show professor appointments screen for professors
    if (_userRole == 'professor') {
      return const ProfessorAppointmentsScreen();
    }

    // Show student appointments screen for everyone else (students, teachers, etc.)
    return const AppointmentsScreen();
  }
}
