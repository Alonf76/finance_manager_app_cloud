enum WorkspaceRole {
  admin,
  editor,
  viewer;

  static WorkspaceRole fromFirestore(Map<String, dynamic>? workspace, String uid) {
    final raw = workspace?['memberRoles'];
    if (raw is! Map) return WorkspaceRole.editor;
    final value = raw[uid]?.toString().toLowerCase();
    switch (value) {
      case 'admin':
        return WorkspaceRole.admin;
      case 'viewer':
        return WorkspaceRole.viewer;
      default:
        return WorkspaceRole.editor;
    }
  }

  bool get canEditLedger => this != WorkspaceRole.viewer;

  bool get canManageWorkspace => this == WorkspaceRole.admin;
}
