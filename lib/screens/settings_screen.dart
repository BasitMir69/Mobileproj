import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_wave/theme/locale_provider.dart';
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/services/notification_service.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await FirestoreService.getUserProfile(user.uid);
  }

  Future<void> _saveNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SectionHeader(label: 'Appearance'),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.setDarkMode(v),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(l10n.language),
              subtitle: const Text('Select app language'),
              trailing: DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ur', child: Text('اردو')),
                ],
                onChanged: (v) {
                  if (v != null) localeProvider.setLocale(Locale(v));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(),
            builder: (context, snap) {
              if (snap.hasData) {
                final role = snap.data?['role'] ?? 'student';
                if (role == 'professor') {
                  return Column(
                    children: [
                      const SectionHeader(label: 'Appointment Management'),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: Icon(Icons.delete_forever,
                              color: Colors.red.shade700),
                          title: const Text('Clear All Appointments',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                              'Delete all appointment bookings from Firestore'),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete all appointments? This cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete All'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;

                            try {
                              await FirestoreService.clearAllAppointments();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'All appointments cleared successfully.')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          const SectionHeader(label: 'Notifications'),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: const Text('Receive app notifications'),
            value: _notifications,
            onChanged: (v) async {
              await _saveNotifications(v);
              if (v) {
                await NotificationService.ensureInitialized();
                await NotificationService.requestPermission();
              }
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Send sample booking reminder'),
            subtitle: const Text('Schedules a test reminder in ~10 seconds'),
            onTap: () async {
              await NotificationService.ensureInitialized();
              await NotificationService.requestPermission();
              final osEnabled =
                  await NotificationService.areOsNotificationsEnabled();
              if (!osEnabled) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Notifications are disabled in system settings.'),
                  ),
                );
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final raw = prefs.getString('bookings') ?? '[]';
              final List list =
                  List.castFrom<dynamic, dynamic>(jsonDecode(raw));
              String body = 'Your appointment is starting soon.';
              int seconds = 10;
              DateTime? dt;
              if (list.isNotEmpty) {
                final last = Map<String, dynamic>.from(list.last as Map);
                final prof = last['professorName'] ?? 'Professor';
                final slot = last['slot'] ?? '';
                body = 'With $prof at $slot';
                dt = parseExplicitDateTimeLocal(slot) ??
                    parseWeeklySlotToNextDateTime(slot);
              }
              if (dt != null) {
                final reminderTime = dt.subtract(const Duration(minutes: 10));
                final now = DateTime.now();
                if (reminderTime.isAfter(now)) {
                  await NotificationService.scheduleAt(
                    dateTime: reminderTime,
                    title: 'Upcoming Appointment',
                    body: body,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Reminder scheduled 10 minutes before appointment.')),
                  );
                  return;
                }
              }
              // Show an immediate sample notification to confirm it works
              await NotificationService.showNow(
                title: 'Upcoming Appointment',
                body: body,
              );
              // Also schedule one ~10 seconds later to demo scheduling
              await NotificationService.scheduleIn(
                seconds: seconds,
                title: 'Upcoming Appointment',
                body: body,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sample reminder scheduled.')),
              );
            },
          ),
          const SizedBox(height: 16),
          const SectionHeader(label: 'Shortcuts'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.myAppointments),
              subtitle: const Text('View or cancel your bookings'),
              onTap: () => context.pushNamed('appointments'),
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(label: 'Tools'),
          // Professor-only: Manage incoming appointment requests
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(),
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final role = userProfile?['role'] ?? 'student';

              if (role == 'professor') {
                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.assignment_outlined),
                        title: const Text('Manage Appointments'),
                        subtitle:
                            const Text('Approve or reject student requests'),
                        onTap: () => context.pushNamed('professorAppointments'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(l10n.sendFeedback),
              subtitle: const Text('Help us improve Campus Wave'),
              onTap: () async {
                final profile = await _getUserProfile();
                final role = (profile?['role'] ?? 'student') as String;
                final email = FirebaseAuth.instance.currentUser?.email ?? '';
                final controller = TextEditingController();
                int rating = 0;
                final sent = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    return StatefulBuilder(builder: (ctx, setStateDialog) {
                      return AlertDialog(
                        title: const Text('Send Feedback'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final filled = i < rating;
                                  return IconButton(
                                    icon: Icon(
                                      filled ? Icons.star : Icons.star_border,
                                      color: filled ? Colors.amber : null,
                                    ),
                                    onPressed: () => setStateDialog(() {
                                      rating = i + 1;
                                    }),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                    hintText: 'Write your feedback here...'),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Send'),
                          ),
                        ],
                      );
                    });
                  },
                );
                if (sent != true) return;
                final msg = controller.text.trim();
                if (msg.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Feedback cannot be empty.')));
                  return;
                }
                try {
                  final url = Uri.parse(
                      'https://us-central1-campuswave-9f2b3.cloudfunctions.net/sendFeedbackEmail');
                  await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'message': msg,
                      'role': role,
                      'userEmail': email,
                      'rating': rating,
                    }),
                  );
                  // Store to Firestore for admin portal
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  await FirebaseFirestore.instance.collection('feedback').add({
                    'userId': uid,
                    'message': msg,
                    'rating': rating,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Feedback sent. Thank you!')));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')));
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(label: 'Account'),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary.withOpacity(0.9),
        ),
      ),
    );
  }
}
