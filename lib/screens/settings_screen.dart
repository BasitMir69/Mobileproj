import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:campus_wave/theme/locale_provider.dart';
import 'package:campus_wave/l10n/app_localizations.dart';

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

  Future<void> _saveNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        // No search button on settings per request
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: Text(l10n.appearance),
              subtitle: const Text('Theme & brightness'),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(l10n.darkMode),
            subtitle: const Text('Use dark theme across the app'),
            value: isDark,
            onChanged: (v) => themeProvider.setDarkMode(v),
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
                  if (v != null) {
                    localeProvider.setLocale(Locale(v));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: const Text('Receive app notifications'),
            value: _notifications,
            onChanged: (v) => _saveNotifications(v),
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
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(l10n.sendFeedback),
              subtitle: const Text('Help us improve Campus Wave'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback form coming soon')));
              },
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            label: 'Clear stored demo appointment bookings',
            hint: 'Removes all locally saved booking records',
            child: Tooltip(
              message: 'Delete local demo booking data',
              child: ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('bookings');
                  messenger?.showSnackBar(
                    SnackBar(content: Text(l10n.clearDemo)),
                  );
                },
                child: Text('${l10n.clearDemo} • Reset'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            label: 'Log out of your account',
            hint: 'Return to login screen',
            child: Tooltip(
              message: 'Sign out',
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  // Ensure Firebase auth state resets so GoRouter redirect shows login
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
            ),
          ),
        ],
      ),
    );
  }
}
