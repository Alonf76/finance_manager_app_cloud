# Product Requirements Document (PRD)

## 1. Purpose
Family Biz Finance is designed to help households manage shared finances while bridging the gap between personal expenses and small family business tracking.

## 2. Functional Requirements
### 2.1 User Management
- **Authentication:** Secure login/registration via Email/Password (Firebase Auth).
- **User Profiles:** Support for user preferences including language (EN/HE) and currency.

### 2.2 Household Workspaces
- **Multi-tenancy:** Users can belong to multiple workspaces.
- **Role-Based Access (RBAC):** Roles include `Admin` (manage members), `Editor` (add/edit data), and `Viewer` (read-only).
- **Member Invites:** Invitation via unique workspace codes or direct email invite.

### 2.3 Finance & Ledger
- **Transaction Tracking:** Log Income and Expenses with Title, Amount, Date, and Category.
- **Business Tagging:** Every transaction must be tagged as "Personal" or "Business".
- **Installments:** Support for splitting transactions over multiple billing cycles.
- **Targeting (Budgets):** Set monthly spending targets per category.

### 2.4 Grocery Module
- **Real-time Sync:** Shared grocery lists that update instantly across all household members.
- **Finance Integration:** Ability to convert a completed grocery list into a ledger expense.

### 2.5 Localization (L10n)
- **Bilingual Support:** Full UI support for English and Hebrew.
- **RTL Support:** Right-to-Left layout adjustment when Hebrew is active.

## 3. Non-Functional Requirements
- **Security:** Data isolation at the Firestore level using Security Rules.
- **Availability:** Offline persistence via Firestore SDK caching.
- **Performance:** Real-time updates for shared lists and ledgers.