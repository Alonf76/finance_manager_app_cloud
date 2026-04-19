# A0 — Technology and inventory audit

**Method:** Static review of repository (`pubspec.yaml`, `lib/`, platform folders, `firebase.json`, `README.md`) on 2026-04-19. No runtime tests were executed in this audit.

---

## 1. Application type and structure

| Item | Finding |
|------|---------|
| Framework | **Flutter** (Dart SDK `^3.11.4` per `pubspec.yaml`) |
| Entry point | `lib/main.dart` — **monolithic** UI + Firestore access (~900 lines in one file) |
| Modularization | **Minimal:** only `lib/firebase_options.dart` besides `main.dart` |
| Tests | Default `test/widget_test.dart` only; **no product/domain tests** observed |

---

## 2. Target platforms (what the repo is set up for)

| Platform | Evidence | Notes |
|----------|----------|--------|
| **Android** | `android/`, `google-services.json`, Gradle Kotlin DSL | Primary mobile target appears ready |
| **iOS** | `ios/`, `AppDelegate.swift`, Firebase options entry for iOS | Present; verify signing & Firebase plist in local Xcode setup |
| **macOS** | `macos/Runner/AppDelegate.swift` | Desktop runner exists |
| **Web** | Firebase `web` configuration in `firebase.json` / `firebase_options.dart` | Flutter web build is plausible |
| **Windows** | Firebase config references Windows in tooling metadata | Flutter Windows folder may exist in full clone; not deep-audited here |

**Conclusion:** Multi-platform **Flutter** app with **Firebase** backend; mobile (Android/iOS) is the natural focus for “Family Biz Finance”.

---

## 3. Backend, database, and sync

| Item | Finding |
|------|---------|
| Backend | **Firebase** — `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Primary datastore | **Cloud Firestore** — collections documented in architecture note |
| Offline / sync | **Implicit** via Firestore client SDK caching; **no explicit offline queue UX** or conflict policy in code |
| API layer | **None** — client talks directly to Firestore |
| Google Sheets | Package **`gsheets`** declared in `pubspec.yaml` but **not referenced** in `lib/*.dart` (likely planned or leftover) |

---

## 4. Authentication and identity

| Item | Finding |
|------|---------|
| Provider | **Firebase Auth — email + password** |
| Session | `authStateChanges()` stream → `AuthWrapper` routes to login vs app |
| Workspace membership | `workspaces` documents store `members` as an **array of email strings**; queries use `arrayContains: user.email` |
| Roles / RBAC | **Not implemented** in code — any member in `members` has full access to workspace data shown in UI |

**Security note:** Firestore **security rules** are **not** versioned in this repository snapshot. Rules must be confirmed in Firebase Console (or added to repo) before any wider beta.

---

## 5. Localization (English + Hebrew requirement)

| Item | Finding |
|------|---------|
| `flutter_localizations` | **Present** — delegates registered on `MaterialApp` |
| Locales | `supportedLocales` is **only** `[Locale('he', 'IL')]`, `locale` **forced** to Hebrew |
| UI strings | **Hard-coded Hebrew** in widgets (no ARB / `gen-l10n` observed) |
| RTL | Hebrew implies RTL; **no English path** yet — bilingual product requirement is **not** met today |

---

## 6. Analytics, crash reporting, CI/CD

| Item | Finding |
|------|---------|
| Analytics | **No** Firebase Analytics / GA dependency in `pubspec.yaml` |
| Crash reporting | **No** Crashlytics / Sentry dependency observed |
| CI/CD | **No** `.github/workflows` (or similar) found in repository snapshot |
| App distribution | **Not** configured in repo (Play Internal / TestFlight scripts absent) |

---

## 7. Dependencies vs actual usage

Declared in `pubspec.yaml` and **used** in `lib/main.dart` (non-exhaustive): `firebase_*`, `cloud_firestore`, `flutter_localizations`, `intl`, `cupertino_icons`.

Declared but **not used** in `lib/` (grep): **`shared_preferences`**, **`path_provider`**, **`gsheets`**.

**Recommendation:** Remove unused packages or implement the features they were meant for; reduces attack surface and confusion.

---

## 8. Product capabilities implemented in code (today)

Implemented in `lib/main.dart`:

- Email registration / login / logout  
- List **workspaces** where current user’s email is in `members`  
- Create workspace with default **categories**, **billing day**, empty **targets**  
- **Transactions** subcollection: income vs expense, category, amount, date, optional **installment series** (`groupId`, split amounts, future months)  
- **Billing cycle** window (from `billingDay` on workspace) for expense summary  
- **Targets** per category (stored on workspace, live-updated from Targets tab)  
- Tabs: Expenses (with category progress), Income, Installments, Targets  
- CRUD: add transaction (with installments), edit amount/title, delete; delete installment series  

**Not implemented** (relative to agreed product direction):

- Grocery lists module  
- Business vs personal tagging on transactions  
- English locale + copy + locale toggle  
- CSV export, budgets as separate concept (targets partially cover this), bank feeds, OCR, invoicing  
- Explicit roles (Admin/Editor/Viewer), invites flow beyond manual Firestore edits  

---

## 9. Summary verdict for planning

The codebase is a **working vertical slice**: **Flutter + Firebase Auth + Firestore** with **Hebrew-only** household finance UI and **real-time** lists from Firestore. It is **pre-production** from a product completeness, i18n, security rules, observability, and engineering structure perspective — which is appropriate for early MVP iteration if scope is managed deliberately (see MVP scope lock).
