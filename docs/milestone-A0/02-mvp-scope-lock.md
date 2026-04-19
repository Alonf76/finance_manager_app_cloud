# A0 — MVP scope lock (go / no-go)

**Purpose:** Freeze what **MVP v1** must include vs what is **explicitly deferred**, aligned with the Family Biz Finance work plan **and** the current codebase reality (Flutter + Firestore + Hebrew household finance).

**Rule:** If it is not in **MVP v1**, it does not block first household beta; it goes to **v1.5 / v2** with dated milestones later.

---

## MVP v1 — IN SCOPE (must ship)

1. **Household workspace**  
   - Create workspace, list workspaces for signed-in user, open workspace.  
   - **Stretch within MVP if time:** invite second member without manual Firestore edits (email invite or join code).

2. **Money ledger (existing features hardened)**  
   - Add / edit / delete transactions; income vs expense; categories; **billing cycle** summary.  
   - **Targets** per category (already present — treat as “budgets lite” for MVP).  
   - **Installments** tab behavior preserved or simplified if buggy edge cases appear.

3. **Bilingual product baseline**  
   - **English + Hebrew** UI; **locale switch**; **RTL** for Hebrew, LTR for English.  
   - Centralized strings (recommended: Flutter `gen-l10n` ARB files).

4. **Business vs personal**  
   - Mandatory (or strongly defaulted) **tag** on each transaction for family biz use case.  
   - Dashboard filter or section split (minimal UI acceptable for MVP).

5. **Grocery module (MVP)**  
   - Multiple lists, items with quantity/notes, check-off, **real-time sync** under same workspace.  
   - **Thin link:** “Log grocery spend” → new expense with grocery category prefilled.

6. **Trust baseline**  
   - **Firestore security rules** reviewed and deployed (documented in repo).  
   - **Account deletion / sign-out** behavior clear; data ownership documented for beta testers.

7. **Release hygiene (lightweight)**  
   - Debug banner off for release builds; version bump discipline.  
   - Manual test checklist for EN/HE + Android (iOS when available).

---

## MVP v1 — OUT OF SCOPE (deferred)

| Item | Deferred to | Reason |
|------|-------------|--------|
| Bank feed aggregation | **v2+** | Compliance, cost, reliability |
| Receipt OCR | **v1.5+** | ML pipeline, privacy review |
| Full double-entry accounting | **Not planned unless requested** | Overkill for household MVP |
| Invoicing + PDF | **v1.5+** unless B2B is immediate pain | Extra UX + storage |
| CSV import | **v1.5** | High value but not blocking first synced MVP |
| Subscription detection | **v2** | Nice-to-have |
| Rich analytics (Firebase Analytics dashboards) | **v1.5** | Add after core flows stable |
| Crashlytics | **v1.5** (strongly recommended before wide release) | Not blocking 3–5 user beta if manual feedback |
| Google Sheets sync (`gsheets` package) | **Decision point** | Either implement story or remove dependency |

---

## Go / no-go decision

**GO** for MVP v1 implementation **provided**:

- Firestore rules are treated as **blocking** before external users.  
- English + Hebrew are treated as **blocking** before calling MVP “complete” (Hebrew-only is **not** acceptable per product charter).  
- Grocery is **blocking** for MVP v1 per product charter (can ship **after** ledger + i18n if you intentionally split releases — then rename milestones; default here is **one MVP bundle**).

**NO-GO** (stop and narrow scope) if:

- Bank feeds or OCR are demanded inside “MVP” — re-scope to **v2** or extend timeline explicitly.

---

## Change control

Any addition to MVP v1 must answer: **(1)** Which milestone does it replace? **(2)** Which week does it land? **(3)** Who owns it?

Otherwise the item defaults to **Phase 5** in the work plan.
