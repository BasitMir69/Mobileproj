import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _displayNameController = TextEditingController();
  String? _base64Photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _displayNameController.text = user?.displayName ?? '';
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _base64Photo = prefs.getString('profilePhotoBase64'));
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePhotoBase64', base64Encode(bytes));
    setState(() => _base64Photo = base64Encode(bytes));
  }

  Future<void> _save() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final name = _displayNameController.text.trim();
      if (name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }
      // Photo stored locally; if future backend used, upload & set photoURL.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (_base64Photo != null) {
      try {
        provider = MemoryImage(base64Decode(_base64Photo!));
      } catch (_) {}
    }
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    backgroundImage: provider,
                    child: provider == null
                        ? Text(
                            (user?.displayName?.isNotEmpty == true
                                    ? user!.displayName!
                                        .trim()
                                        .split(RegExp(r"\\s+"))
                                        .map((e) => e[0])
                                        .take(2)
                                        .join()
                                        .toUpperCase()
                                    : user?.email?.characters.first
                                        .toUpperCase()) ??
                                '?',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            Text(user?.email ?? '',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_alt),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
