import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campus_wave/widgets/cw_logo.dart';
import 'package:campus_wave/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/widgets/google_sign_in_button.dart';
import 'package:campus_wave/services/firestore_service.dart';

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({super.key});

  @override
  State<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends State<LoginScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String _userRole = 'student'; // auto-detected after login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String> _detectRole(String uid) async {
    // Use stored user profile role only (Option B)
    final userProfile = await FirestoreService.getUserProfile(uid);
    final role = (userProfile != null && userProfile['role'] is String)
        ? (userProfile['role'] as String)
        : 'student';
    return role;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Auto-detect role from Firestore (professor vs student)
      if (_auth.currentUser != null) {
        try {
          _userRole = await _detectRole(_auth.currentUser!.uid);
          await FirestoreService.setUserProfile(
            userId: _auth.currentUser!.uid,
            displayName: _auth.currentUser!.displayName ?? '',
            email: _auth.currentUser!.email ?? '',
            role: _userRole,
          );
        } catch (e) {
          debugPrint('❌ Failed to detect/save user role: $e');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)),
      );
      if (!mounted) return;
      // Navigate based on role (no professor dashboard)
      final route = _userRole == 'admin' ? '/admin' : '/home';
      context.go(route);
    } on FirebaseAuthException catch (e) {
      final l10n = AppLocalizations.of(context)!;
      final msg = e.message ?? l10n.loginFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l10n.loginFailed}: $msg')));
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l10n.loginFailed}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);

      // Save/update user profile in Firestore with auto-detected role
      if (cred.user != null) {
        try {
          _userRole = await _detectRole(cred.user!.uid);
          await FirestoreService.setUserProfile(
            userId: cred.user!.uid,
            displayName: cred.user!.displayName ?? '',
            email: cred.user!.email ?? '',
            role: _userRole,
          );
          debugPrint('✅ User profile saved to Firestore: ${cred.user!.uid}');
        } catch (firestoreError) {
          debugPrint('❌ Failed to save user profile: $firestoreError');
          // Continue anyway - user is already authenticated
        }
      }

      if (!mounted) return;
      final route = _userRole == 'admin' ? '/admin' : '/home';
      context.go(route);
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l10n.loginFailed}: $e')));
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
                                size: 140, color: theme.colorScheme.primary)),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            l10n.welcome,
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
                            l10n.guide,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tp.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email
                          ],
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
                          controller: _passwordController,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
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
                          label: l10n.login,
                          loading: _isLoading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 12),
                        GoogleSignInButton(
                          onPressed: _signInWithGoogle,
                          loading: _isLoading,
                          label: 'Sign in with Google',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.or,
                                style: TextStyle(color: tp.secondaryTextColor)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: l10n.createAccount,
                          secondary: true,
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/createAccount'),
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
