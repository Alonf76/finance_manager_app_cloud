import 'package:family_biz_finance/screens/main_finance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              // Navigate to the real MainFinanceScreen (Ledger)
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const MainFinanceScreen(
                        wsId: 'default-workspace',
                        wsName: 'Family Biz',
                      )));
            },
            child: Text(l10n.ledgerTitle)),
      ),
    );
  }
}
