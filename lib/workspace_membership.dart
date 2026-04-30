import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'invite_code.dart';

/// Migrates legacy `members` (emails) workspaces to also include `memberIds`,
/// roles, and invite metadata used by M1.
class WorkspaceMembership {
  WorkspaceMembership._();

  static Future<void> migrateLegacyMembership(User user) async {
    final email = user.email;
    if (email == null) return;

    final legacy = await FirebaseFirestore.instance
        .collection('workspaces')
        .where('members', arrayContains: email)
        .get();

    for (final doc in legacy.docs) {
      final data = doc.data();
      final memberIds = List<String>.from((data['memberIds'] as List?) ?? const []);
      if (memberIds.contains(user.uid)) continue;

      final memberRoles = Map<String, dynamic>.from(
        (data['memberRoles'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      if (!memberRoles.containsKey(user.uid)) {
        // First migrated UID becomes admin if nobody is admin yet.
        final hasAdmin = memberRoles.values.any((v) => v?.toString().toLowerCase() == 'admin');
        memberRoles[user.uid] = hasAdmin ? 'editor' : 'admin';
      }

      final inviteCode = (data['inviteCode'] as String?)?.trim();
      final patch = <String, dynamic>{
        'memberIds': FieldValue.arrayUnion([user.uid]),
        'memberRoles': memberRoles,
      };
      if (inviteCode == null || inviteCode.isEmpty) {
        patch['inviteCode'] = generateInviteCode();
      }
      if (data['pendingInviteEmails'] == null) {
        patch['pendingInviteEmails'] = <String>[];
      }

      await doc.reference.update(patch);
    }
  }

  static Future<void> createWorkspace({
    required User user,
    required String name,
    required List<String> defaultCategories,
  }) async {
    final email = user.email;
    await FirebaseFirestore.instance.collection('workspaces').add({
      'name': name,
      if (email != null) 'members': [email],
      'memberIds': [user.uid],
      'memberRoles': {user.uid: 'admin'},
      'inviteCode': generateInviteCode(),
      'pendingInviteEmails': <String>[],
      'billingDay': 10,
      'customCategories': defaultCategories,
      'targets': <String, dynamic>{},
    });
  }

  static Future<void> inviteByEmail({
    required String workspaceId,
    required String email,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;
    await FirebaseFirestore.instance.collection('workspaces').doc(workspaceId).update({
      'pendingInviteEmails': FieldValue.arrayUnion([normalized]),
    });
  }

  static Future<void> acceptEmailInvite({
    required String workspaceId,
    required User user,
  }) async {
    final email = user.email?.trim().toLowerCase();
    if (email == null) return;

    final ref = FirebaseFirestore.instance.collection('workspaces').doc(workspaceId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final pending = List<String>.from((data['pendingInviteEmails'] as List?) ?? const []);
      if (!pending.contains(email)) return;

      final memberIds = List<String>.from((data['memberIds'] as List?) ?? const []);
      if (!memberIds.contains(user.uid)) {
        memberIds.add(user.uid);
      }

      final roles = Map<String, dynamic>.from(
        (data['memberRoles'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      roles.putIfAbsent(user.uid, () => 'editor');

      pending.remove(email);

      tx.update(ref, {
        'memberIds': memberIds,
        'memberRoles': roles,
        'pendingInviteEmails': pending,
      });
    });
  }

  static Future<void> declineEmailInvite({
    required String workspaceId,
    required String email,
  }) async {
    final normalized = email.trim().toLowerCase();
    await FirebaseFirestore.instance.collection('workspaces').doc(workspaceId).update({
      'pendingInviteEmails': FieldValue.arrayRemove([normalized]),
    });
  }

  static Future<String?> joinWithInviteCode({
    required User user,
    required String code,
  }) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return null;

    final q = await FirebaseFirestore.instance
        .collection('workspaces')
        .where('inviteCode', isEqualTo: trimmed)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;

    final doc = q.docs.first;
    final data = doc.data();
    final memberIds = List<String>.from((data['memberIds'] as List?) ?? const []);
    if (memberIds.contains(user.uid)) return doc.id;

    memberIds.add(user.uid);
    final roles = Map<String, dynamic>.from(
      (data['memberRoles'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    roles.putIfAbsent(user.uid, () => 'editor');

    await doc.reference.update({
      'memberIds': memberIds,
      'memberRoles': roles,
    });
    return doc.id;
  }
}
