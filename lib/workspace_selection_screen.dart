import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:family_biz_finance/features/ledger/screens/ledger_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkspaceSelectionScreen extends StatelessWidget {
  const WorkspaceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspaceSelectionTitle),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              // Placeholder: In a real app, you'd select a workspace and then navigate
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LedgerScreen()));
            },
            child: const Text("Go to Ledger (Placeholder)")),
      ),
    );
  }
}
