import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campus_wave/widgets/cw_logo.dart';
import 'package:campus_wave/widgets/app_button.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)),
      );
      if (!mounted) return;
      context.go('/home');
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
      await _auth.signInWithCredential(credential);
      if (!mounted) return;
      if (!mounted) return;
      context.go('/home');
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
                        AppButton(
                          label: 'Sign in with Google',
                          secondary: true,
                          icon: Icons.g_mobiledata,
                          loading: _isLoading,
                          onPressed: _signInWithGoogle,
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
                        const SizedBox(height: 26),
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => context.go('/home'),
                          child: Text(l10n.exploreGuest),
                        ),
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
