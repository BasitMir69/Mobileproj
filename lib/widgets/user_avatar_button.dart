import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAvatarButton extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  const UserAvatarButton({super.key, this.size = 34, this.onTap});

  @override
  State<UserAvatarButton> createState() => _UserAvatarButtonState();
}

class _UserAvatarButtonState extends State<UserAvatarButton> {
  String? _base64;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _base64 = prefs.getString('profilePhotoBase64'));
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    ImageProvider? provider;
    if (_base64 != null) {
      try {
        final bytes = base64Decode(_base64!);
        provider = MemoryImage(bytes);
      } catch (_) {}
    }
    final initials = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
            .trim()
            .split(RegExp(r"\s+"))
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : (user?.email?.characters.first.toUpperCase() ?? '?');

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(widget.size / 2),
      child: CircleAvatar(
        radius: widget.size / 2,
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        backgroundImage: provider,
        child: provider == null
            ? Text(initials,
                style: TextStyle(
                    fontSize: widget.size / 2.2, fontWeight: FontWeight.w600))
            : null,
      ),
    );
  }
}
