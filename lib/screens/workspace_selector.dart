import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/app_theme.dart';
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

const _avatarHues = [0, 152, 210]; // accent, positive, a cool blue-teal for variety

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
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
        content: TextField(controller: ctrl, autofocus: true),
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
          decoration: InputDecoration(labelText: l10n.enterInviteCode),
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

  Widget _iconButton({required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    final palette = AppColors.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: palette.line, width: 1.5),
          ),
          child: Icon(icon, size: 19, color: palette.inkSoft),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
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
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.myWorkspaces, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 25)),
                          Row(
                            children: [
                              _iconButton(
                                icon: Icons.manage_accounts_outlined,
                                tooltip: l10n.profileSettings,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                icon: Icons.logout_rounded,
                                tooltip: l10n.signOut,
                                onPressed: () => FirebaseAuth.instance.signOut(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        children: [
                          if (invDocs.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                l10n.pendingInvitesTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: palette.inkFaint,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            ...invDocs.map((d) {
                              final name = d.data()['name']?.toString() ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: palette.surfaceTint,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(Icons.mail_outline_rounded, color: palette.accentDeep, size: 19),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                          const SizedBox(height: 1),
                                          Text(l10n.invitedToJoin, style: TextStyle(fontSize: 12.5, color: palette.inkSoft)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 14),
                                              minimumSize: Size.zero,
                                              textStyle: const TextStyle(fontSize: 12.5),
                                            ),
                                            onPressed: () => WorkspaceMembership.acceptEmailInvite(
                                              workspaceId: d.id,
                                              user: user,
                                            ),
                                            child: Text(l10n.acceptInvite),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: user.email == null
                                              ? null
                                              : () => WorkspaceMembership.declineEmailInvite(
                                                    workspaceId: d.id,
                                                    email: user.email!.toLowerCase(),
                                                  ),
                                          child: Text(l10n.declineInvite, style: const TextStyle(fontSize: 12.5)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                          if (wsDocs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                l10n.yourWorkspaces.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: palette.inkFaint,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          if (wsDocs.isEmpty && invDocs.isEmpty)
                            SizedBox(
                              height: 320,
                              child: Center(
                                child: Text(
                                  l10n.noActiveWorkspaces,
                                  style: TextStyle(color: palette.inkSoft),
                                ),
                              ),
                            ),
                          ...wsDocs.asMap().entries.map((entry) {
                            final data = entry.value.data();
                            final name = data['name']?.toString() ?? '';
                            final hue = _avatarHues[entry.key % _avatarHues.length];
                            final avatarColor = hue == 0
                                ? theme.colorScheme.primary
                                : hue == 152
                                    ? palette.positive
                                    : const Color(0xFF3F8E9E);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MainFinanceScreen(wsId: entry.value.id, wsName: name),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: palette.line, width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(14)),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _initials(name),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                        ),
                                        Icon(Icons.chevron_right_rounded, color: palette.inkFaint),
                                      ],
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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showCreateWorkspace(context),
                            icon: const Icon(Icons.add_rounded, size: 19),
                            label: Text(l10n.createNewFamilyWorkspace),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _showJoinWorkspace(context),
                            icon: const Icon(Icons.vpn_key_outlined, size: 18),
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
      ),
    );
  }
}
