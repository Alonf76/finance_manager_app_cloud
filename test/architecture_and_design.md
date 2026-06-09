# Architecture and Design Document

## 1. High-Level Tech Stack
- **Frontend:** Flutter (Mobile, Web, Desktop).
- **Backend:** Firebase (Auth, Firestore, Hosting).
- **State Management:** Stream-based (Firestore Snapshots) and Widget-level state.
- **Localization:** ARB-based code generation (`flutter_gen`).

## 2. Project Structure (Feature-Based)
The project follows a modular "Feature-based" folder structure to prevent logic bloat:

- `lib/core/`: Shared constants, themes, and utility formatters.
- `lib/features/auth/`: Authentication logic and login/register screens.
- `lib/features/workspace/`: Workspace selection, creation, and member management.
- `lib/features/ledger/`: Transaction processing, installment logic, and budget views.
- `lib/features/grocery/`: Shared list management.

## 3. Data Model (Firestore)
### 3.1 Workspaces Collection
Documents contain `memberIds`, `memberRoles`, and `billingDay`.

### 3.2 Transactions Sub-collection
Nested under `workspaces/{workspaceId}/transactions`. Includes `groupId` for installment linking.

### 3.3 Users Collection
Stores global preferences such as `preferredLocale` and `currencyCode`.

## 4. Security Architecture
Security is enforced via **Firestore Security Rules**. 
- Access to a workspace document requires the user's UID to exist in the `memberIds` array.
- Sub-collections inherit access rights based on the parent workspace membership.

## 5. UI Design Patterns
- **AuthWrapper:** A root-level listener that switches between the Login flow and the App flow based on the Auth state.
- **Bilingual Layout:** Uses `Directionality` and `AppLocalizations` to handle LTR (English) and RTL (Hebrew) dynamically.