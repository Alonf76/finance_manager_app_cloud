import 'package:family_biz_finance/screens/login_screen.dart';
import 'package:family_biz_finance/screens/workspace_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// This widget listens to Firebase Auth state changes and routes the user
/// to the appropriate screen (Login or Workspace Selection).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // User is signed in, navigate to workspace selection
          return const WorkspaceSelector();
        } else {
          // User is signed out, navigate to login
          return const LoginScreen();
        }
      },
    );
  }
}
