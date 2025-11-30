import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookings') ?? '[]';
    final List list = json.decode(raw) as List;
    final items = list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .where((e) => user != null && e['userUid'] == user.uid)
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) =>
          (a['createdAt'] as String).compareTo(b['createdAt'] as String));
    setState(() {
      _bookings = items;
      _loading = false;
    });
  }

  Future<void> _removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookings') ?? '[]';
    final List list = json.decode(raw) as List;
    final target = _bookings[index];
    final pos = list.indexWhere((e) =>
        e is Map &&
        e['createdAt'] == target['createdAt'] &&
        e['professorId'] == target['professorId']);
    if (pos >= 0) {
      list.removeAt(pos);
      await prefs.setString('bookings', json.encode(list));
    }
    await _loadBookings();
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Clear all bookings?'),
            content:
                const Text('This will remove all your locally saved bookings.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Clear')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookings', '[]');
    await _loadBookings();
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
        actions: [
          if (_bookings.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearAll,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('professors'),
        icon: const Icon(Icons.person_search),
        label: const Text('Find Professors'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No appointments yet. Book with a professor!'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => context.pushNamed('professors'),
                        icon: const Icon(Icons.person_search),
                        label: const Text('Find Professors'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _bookings.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final b = _bookings[i];
                    final name = b['professorName'] ?? b['professorId'];
                    final slot = b['slot'] ?? '';
                    final created = b['createdAt'] ?? '';
                    return Dismissible(
                      key: ValueKey('${b['professorId']}_${b['createdAt']}'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancel appointment?'),
                                content:
                                    Text('Remove booking for $name ($slot)?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('No')),
                                  ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Yes, cancel')),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) => _removeAt(i),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.calendar_today)),
                        title: Text(name.toString()),
                        subtitle: Text('Slot: $slot\nBooked: $created'),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'View professors',
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => context.pushNamed('professors'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
