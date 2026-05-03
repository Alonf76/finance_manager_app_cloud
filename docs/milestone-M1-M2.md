# Milestones M1 / M2 — Implementation notes

**Date:** 2026-04-19  

## What shipped in the app

### M1 — Household workspace + roles

- **Membership model:** `memberIds` (UID array) is the primary membership field for queries. Legacy `members` (email array) is kept for backward compatibility and migration.
- **Roles:** `memberRoles` map on each workspace: `admin`, `editor`, `viewer`.
- **Migration:** On workspace list load, the app attempts to attach the signed-in user’s UID to any legacy workspace where their email is still listed under `members`, and backfills `inviteCode` / `pendingInviteEmails` when missing.
- **Invites:**
  - **Invite code** (`inviteCode`) shown to admins in workspace settings; copy to clipboard; join flow queries by code.
  - **Email invites** via `pendingInviteEmails` + accept/decline UI on the workspace list.
- **User profile (`users/{uid}`):** `preferredLocale` (`en` / `he`), `timezone` (IANA string), `currencyCode` (`ILS` / `USD` / `EUR`).
- **UI enforcement:** `viewer` cannot add/edit/delete transactions, edit targets, or delete installment series. Only `admin` sees workspace invite settings.

### M2 — English / Hebrew + formatting

- **Strings:** Centralized in `lib/l10n/app_localizations.dart` (hand-maintained for reliable builds; see `docs/l10n/README.md` for optional ARB/codegen path).
- **Locale switching:** Profile screen segmented control updates `preferredLocale` in Firestore; authenticated `MaterialApp` rebuilds with `Locale('en')` or `Locale('he','IL')` (RTL for Hebrew via Flutter’s built-in directionality).
- **Numbers/dates:** `intl` `NumberFormat.currency` and `DateFormat` use the active `Locale` (`lib/app_formatters.dart`).
### UI & UX Polish
- **Full Editability:** Transaction editing now matches the "Add" experience, including type toggling (Income/Expense), category creation, and installment support.
- **Version Visibility:** App version (e.g., `v1.0.0+3`) is now displayed in the Browser Tab Title, the AppBar (near settings), and the Navigation Drawer.

## Firestore fields added/changed

| Field | Where | Purpose |
|-------|--------|---------|
| `memberIds` | `workspaces/*` | UID membership |
| `memberRoles` | `workspaces/*` | UID → role |
| `inviteCode` | `workspaces/*` | Join code |
| `pendingInviteEmails` | `workspaces/*` | Pending email invites (lowercased) |
| `users/{uid}` | top-level collection | Profile + preferences |

## Follow-ups (recommended)

- Tighten **Firestore security rules** (see `docs/firestore.rules.sample` as a starting sketch only — validate against your auth token fields and role model).
- Add **widget/integration tests** with Firebase emulator.
- Consider **gen-l10n** once you want translator workflow with ARB files exclusively.
