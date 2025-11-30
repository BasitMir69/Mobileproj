import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookings') ?? '[]';
    final List list = json.decode(raw) as List;
    setState(() {
      _bookings = List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e)));
    });
  }

  Future<void> _cancel(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _bookings.removeAt(index);
    await prefs.setString('bookings', json.encode(_bookings));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _bookings.isEmpty
            ? const Center(child: Text('No appointments booked yet'))
            : ListView.separated(
                itemCount: _bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = _bookings[i];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    child: ListTile(
                      title: Text(b['professorName'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          '${b['slot'] ?? ''}\n${b['userName'] ?? ''} • ${b['userEmail'] ?? ''}',
                          style: TextStyle(color: Colors.grey[400])),
                      isThreeLine: true,
                      trailing: TextButton(
                        onPressed: () => _cancel(i),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
