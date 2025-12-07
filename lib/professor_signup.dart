import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:campus_wave/widgets/cw_logo.dart';
import 'package:campus_wave/widgets/app_button.dart';
import 'package:campus_wave/services/firestore_service.dart';

class ProfessorSignupScreen extends StatefulWidget {
  const ProfessorSignupScreen({super.key});

  @override
  State<ProfessorSignupScreen> createState() => _ProfessorSignupScreenState();
}

class _ProfessorSignupScreenState extends State<ProfessorSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _campusController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update display name
      final name = _nameController.text.trim();
      await cred.user?.updateDisplayName(name);

      if (cred.user != null) {
        try {
          // Save professor profile to Firestore
          await FirestoreService.setUserProfile(
            userId: cred.user!.uid,
            displayName: name,
            email: cred.user!.email ?? '',
            role: 'professor',
          );

          // Create professor document with additional details
          await FirestoreService.setProfessorProfile(
            userId: cred.user!.uid,
            name: name,
            campus: _campusController.text.trim(),
            department: _departmentController.text.trim(),
            title: _titleController.text.trim().isEmpty
                ? 'Sir'
                : _titleController.text.trim(),
          );

          debugPrint(
              '✅ Professor profile saved to Firestore: ${cred.user!.uid}');
        } catch (firestoreError) {
          debugPrint('❌ Failed to save professor profile: $firestoreError');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.signupSuccess)),
      );
      if (!mounted) return;
      context.go('/professorHome');
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Signup failed';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l10n.signupFailed}: $msg')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l10n.signupFailed}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: tp.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                            child: CwLogo(
                                size: 120, color: theme.colorScheme.primary)),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Professor Registration',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: tp.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Create your professor account to manage appointments',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tp.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            return text.isEmpty ? 'Name is required' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            if (text.isEmpty) return 'Email is required';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(text);
                            return ok ? null : 'Enter a valid email';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Title (e.g., Dr., Prof., Sir)',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _departmentController,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Department',
                            prefixIcon: const Icon(Icons.business_outlined),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            return text.isEmpty
                                ? 'Department is required'
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _campusController,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Campus',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            return text.isEmpty ? 'Campus is required' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          style: TextStyle(color: tp.primaryTextColor),
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscure ? 'Show password' : 'Hide password',
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: tp.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            if (text.isEmpty) return 'Password is required';
                            if (text.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Register as Professor',
                          loading: _isLoading,
                          onPressed: _signup,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already registered?',
                              style: TextStyle(color: tp.secondaryTextColor),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => context.go('/login'),
                              child: const Text('Login here'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
