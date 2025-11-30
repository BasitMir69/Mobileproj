import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_wave/models/professor.dart';
import 'package:campus_wave/data/campus_professors.dart';

class ProfessorDetailScreen extends StatefulWidget {
  final Professor professor;

  const ProfessorDetailScreen({super.key, required this.professor});

  @override
  State<ProfessorDetailScreen> createState() => _ProfessorDetailScreenState();
}

class _ProfessorDetailScreenState extends State<ProfessorDetailScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
  }

  void _bookSlot(String slot) async {
    final user = _auth.currentUser;
    if (user == null) {
      final goLogin = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign in required'),
              content: const Text('Please log in to book an appointment slot.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Go to Login')),
              ],
            ),
          ) ??
          false;
      if (goLogin) {
        if (mounted) context.go('/login');
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Book the slot:\n$slot\nwith ${widget.professor.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookings') ?? '[]';
    final List list = json.decode(raw) as List;
    final booking = {
      'professorId': widget.professor.id,
      'professorName': widget.professor.name,
      'slot': slot,
      'userUid': user.uid,
      'userEmail': user.email,
      'userDisplayName': user.displayName,
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.add(booking);
    await prefs.setString('bookings', json.encode(list));

    if (!mounted) return;
    // Navigate to My Appointments as confirmation
    context.go('/appointments');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.professor;
    final theme = Theme.of(context);
    // Attempt to cast to extended to show skills/achievements if available
    final extended = p is ProfessorExtended ? p : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(p.photoUrl),
              ),
            ),
            const SizedBox(height: 12),
            Text(p.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(p.department, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(p.bio, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Office: ${p.office}', style: theme.textTheme.bodySmall),
            if (extended != null) ...[
              const SizedBox(height: 18),
              Text('Skills & Subjects', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    extended.skills.map((s) => Chip(label: Text(s))).toList(),
              ),
              const SizedBox(height: 16),
              Text('Student Achievements', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              ...extended.achievements.map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(a)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 18),
            Text('Available Slots', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.availableSlots.map((s) {
                return Semantics(
                  button: true,
                  label: 'Book slot $s',
                  hint: 'Tap to reserve $s with ${p.name}',
                  child: ActionChip(
                    avatar: const Icon(Icons.schedule, size: 18),
                    label: Text(s),
                    onPressed: () => _bookSlot(s),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
