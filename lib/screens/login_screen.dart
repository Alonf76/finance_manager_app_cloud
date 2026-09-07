import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/app_theme.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';

import '../user_profile_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() => _submitting = true);
    try {
      final trimmedEmail = _email.text.trim();
      final trimmedPass = _pass.text.trim();
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: trimmedEmail,
          password: trimmedPass,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: trimmedPass,
        );
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserProfileRepository.ensureProfile(user);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    final palette = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.inkSoft)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          autocorrect: false,
          keyboardType: keyboardType,
          decoration: const InputDecoration(isDense: false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: palette.surfaceTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, color: palette.accentDeep, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.appTitle, style: theme.textTheme.titleMedium?.copyWith(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                _isLogin ? l10n.signIn : l10n.signUp,
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(fontSize: 15, color: palette.inkSoft, height: 1.5),
              ),
              const SizedBox(height: 36),
              _field(label: l10n.email, controller: _email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _field(label: l10n.password, controller: _pass, obscure: true),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submitting ? null : () => _submit(l10n),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(_isLogin ? l10n.signIn : l10n.signUp),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? l10n.noAccount : l10n.haveAccount,
                    style: TextStyle(color: palette.inkSoft, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
