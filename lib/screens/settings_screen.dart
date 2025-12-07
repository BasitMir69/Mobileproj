import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.setDarkMode(v),
            ),
          ),
          const SizedBox(height: 12),
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
          // Professor-only: Manage incoming appointment requests
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(),
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final role = userProfile?['role'] ?? 'student';

              if (role == 'professor') {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: const Text('Manage Appointments'),
                    subtitle: const Text('Approve or reject student requests'),
                    onTap: () => context.pushNamed('professorAppointments'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 12),
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
                final sent = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Send Feedback'),
                      content: TextField(
                        controller: controller,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            hintText: 'Write your feedback here...'),
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
                  final resp = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'message': msg,
                      'role': role,
                      'userEmail': email,
                    }),
                  );
                  if (resp.statusCode == 200) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Feedback sent. Thank you!')));
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to send: ${resp.statusCode}')));
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')));
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          // Admin-only: Professor data migration tool
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserProfile(),
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final role = userProfile?['role'] ?? 'student';

              // Show migration tool for professors (can be changed to admin-only)
              if (role == 'professor') {
                return Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.cloud_upload, color: Colors.orange),
                    title: const Text('Professor Data Migration'),
                    subtitle:
                        const Text('Sync static data to Firestore (one-time)'),
                    onTap: () => context.pushNamed('professorMigration'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: 'Delete local booking data',
            child: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('bookings');
                await prefs.remove('professorBookings');
                messenger.showSnackBar(
                  const SnackBar(content: Text('Bookings cleared.')),
                );
              },
              child: const Text('Clear Bookings'),
            ),
          ),
          const SizedBox(height: 24),
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
