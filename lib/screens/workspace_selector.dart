import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';

import '../default_categories.dart';
import '../user_profile_repository.dart';
import '../workspace_membership.dart';
import 'main_finance_screen.dart';
import 'profile_settings_screen.dart';

Stream<QuerySnapshot<Map<String, dynamic>>> _inviteSnapshots(User user) async* {
  if (user.email == null) {
    yield await FirebaseFirestore.instance.collection('workspaces').limit(0).get();
    return;
  }
  final normalized = user.email!.trim().toLowerCase();
  yield* FirebaseFirestore.instance
      .collection('workspaces')
      .where('pendingInviteEmails', arrayContains: normalized)
      .snapshots();
}

class WorkspaceSelector extends StatefulWidget {
  const WorkspaceSelector({super.key});

  @override
  State<WorkspaceSelector> createState() => _WorkspaceSelectorState();
}

class _WorkspaceSelectorState extends State<WorkspaceSelector> {
  bool _migrationDone = false;
  String? _migrationError;

  @override
  void initState() {
    super.initState();
    _runMigration();
  }

  Future<void> _runMigration() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await UserProfileRepository.ensureProfile(user);
      await WorkspaceMembership.migrateLegacyMembership(user);
    } catch (e) {
      if (mounted) setState(() => _migrationError = e.toString());
    } finally {
      if (mounted) setState(() => _migrationDone = true);
    }
  }

  Future<void> _showCreateWorkspace(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workspaceName),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
    if (created != true) return;
    if (!context.mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await WorkspaceMembership.createWorkspace(
      user: user,
      name: ctrl.text.trim(),
      defaultCategories: defaultWorkspaceCategories(l10n),
    );
  }

  Future<void> _showJoinWorkspace(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    final joined = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.joinWorkspace),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: l10n.enterInviteCode,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.join)),
        ],
      ),
    );
    if (joined != true) return;
    if (!context.mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final wsId = await WorkspaceMembership.joinWithInviteCode(user: user, code: ctrl.text);
    if (!context.mounted) return;
    if (wsId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inviteInvalid)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.joinSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser!;
    if (!_migrationDone) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myWorkspaces)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_migrationError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myWorkspaces)),
        body: Center(child: Text(l10n.errorWithMessage(_migrationError!))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWorkspaces),
        actions: [
          IconButton(
            tooltip: l10n.profileSettings,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            ),
            icon: const Icon(Icons.manage_accounts),
          ),
          IconButton(
            tooltip: l10n.signOut,
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('workspaces')
            .where('memberIds', arrayContains: user.uid)
            .snapshots(),
        builder: (context, wsSnap) {
          if (!wsSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _inviteSnapshots(user),
            builder: (context, invSnap) {
              if (!invSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final wsDocs = wsSnap.data!.docs;
              final invDocs = invSnap.data!.docs;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (invDocs.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                l10n.pendingInvitesTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          ...invDocs.map((d) {
                            final name = d.data()['name']?.toString() ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(name),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: user.email == null
                                          ? null
                                          : () async {
                                              await WorkspaceMembership.declineEmailInvite(
                                                workspaceId: d.id,
                                                email: user.email!.toLowerCase(),
                                              );
                                            },
                                      child: Text(l10n.declineInvite),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        await WorkspaceMembership.acceptEmailInvite(
                                          workspaceId: d.id,
                                          user: user,
                                        );
                                      },
                                      child: Text(l10n.acceptInvite),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(height: 24),
                        ],
                        if (wsDocs.isEmpty && invDocs.isEmpty)
                          SizedBox(
                            height: 320,
                            child: Center(child: Text(l10n.noActiveWorkspaces)),
                          ),
                        ...wsDocs.map((doc) {
                          final data = doc.data();
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.group, color: Colors.teal),
                              title: Text(data['name']?.toString() ?? ''),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainFinanceScreen(
                                    wsId: doc.id,
                                    wsName: data['name']?.toString() ?? '',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateWorkspace(context),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createNewFamilyWorkspace),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showJoinWorkspace(context),
                          icon: const Icon(Icons.vpn_key),
                          label: Text(l10n.joinWorkspace),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
