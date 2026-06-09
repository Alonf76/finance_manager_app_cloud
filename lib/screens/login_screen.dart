import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.teal,
              ),
              const SizedBox(height: 20),
              Text(
                _isLogin ? l10n.signIn : l10n.signUp,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final trimmedEmail = _email.text.trim();
                      final trimmedPass = _pass.text.trim();
                      if (_isLogin) {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: trimmedEmail,
                          password: trimmedPass,
                        );
                      } else {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: trimmedEmail,
                              password: trimmedPass,
                            );
                      }
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await UserProfileRepository.ensureProfile(user);
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.errorWithMessage(e.toString())),
                        ),
                      );
                    }
                  },
                  child: Text(_isLogin ? l10n.signIn : l10n.signUp),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? l10n.noAccount : l10n.haveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
