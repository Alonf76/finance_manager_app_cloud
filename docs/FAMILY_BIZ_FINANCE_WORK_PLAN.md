# Family Biz Finance — Work plan

**Purpose:** Follow this document as the master roadmap. Update dates and checkboxes as you progress.

**Last updated:** 2026-04-19 (Milestone A0 completed — see `docs/milestone-A0/README.md`)

---

## Product anchor (short)

- **Mobile-first** family business + household money + **grocery lists**.
- **Languages:** English and Hebrew (**RTL** for Hebrew).
- **Household workspace** with roles and shared data.

*(Full requirements live in your product notes or PRD; this file focuses on execution.)*

---

## Critical path

**Auth + household model → sync/data model → RTL/i18n across MVP screens → money correctness (tags, categories, reports) → grocery real-time collaboration.**

If any link in this chain slips, stop adding features and fix the foundation.

---

## Phase 0 — Baseline inventory (1–3 days)

**Milestone A0 — Current-state map (go/no-go for scope)**

- [x] Audit what exists: platforms (iOS/Android/web), backend, DB, auth, analytics, CI/CD.
- [x] Lock **MVP boundary** vs defer (bank feeds, OCR, invoicing).
- [x] One-pager: core **user journeys**, **data entities**, **release target**.

**Outputs:** architecture sketch, MVP scope lock, risk register — delivered under **`docs/milestone-A0/`** (see `README.md` there).

---

## Phase 1 — Product foundation (1–2 weeks)

**Milestone M1 — Household workspace + roles**

- [ ] Household creation, invites, membership.
- [ ] Roles: Admin / Editor / Viewer (adjust names to your product).
- [ ] Profile: language (EN/HE), timezone, default currency.

**Milestone M2 — Design system + RTL/i18n baseline**

- [ ] Externalize strings; Hebrew copy; RTL layout (nav, forms, lists).
- [ ] Locale-aware dates, numbers, currency; smoke tests in both languages.

**Gate:** No new feature screens ship without passing EN + HE RTL review.

---

## Phase 2 — Money MVP (2–4 weeks, after M2)

**Milestone M3 — Transaction ledger v1**

- [ ] CRUD transactions: amount, date, payment method, category, memo.
- [ ] Optional receipt attachment (photo/PDF).
- [ ] Mandatory **Business vs Personal** tag; optional tax-deductible (if relevant).

**Milestone M4 — Dashboard + reporting v1**

- [ ] Month view: income, expense, net; category breakdown.
- [ ] CSV export for a date range.

**Milestone M5 — Budgets v1 (optional for MVP; high value)**

- [ ] Monthly category caps; alerts at thresholds (e.g. 80% / 100%).

**Gate — Financial correctness**

- [ ] Rules agreed: month boundaries (timezone), rounding, edit/delete behavior, export fidelity.

---

## Phase 3 — Grocery module MVP (1–3 weeks; can overlap Phase 2)

**Milestone G1 — Lists + items + organization**

- [ ] Multiple lists; quantity, unit, notes; reorder; check off while shopping.
- [ ] Categories / aisles (or equivalent grouping).

**Milestone G2 — Household sync v1**

- [ ] Real-time updates across members; offline read + queued writes (as feasible).
- [ ] Conflict policy documented (e.g. last-write-wins + activity feed).

**Milestone G3 — Staples + templates**

- [ ] Favorites / staples; reusable templates (e.g. weekly shop).

**Milestone G4 — Checkout → expense (thin integration)**

- [ ] Flow from grocery session to log household grocery spend (prefilled category).

---

## Phase 4 — Hardening for mobile launch (1–2 weeks)

**Milestone H1 — Performance + reliability**

- [ ] Cold start and scroll performance; receipt image compression if applicable.

**Milestone H2 — Security + privacy baseline**

- [ ] Session handling; biometrics reopen (if applicable); account deletion / export story.

**Milestone H3 — Release readiness**

- [ ] EN/HE RTL test matrix; accessibility pass; crash reporting; staged rollout plan.

---

## Phase 5 — Post-MVP (sequence by user pain)

1. [ ] CSV import  
2. [ ] Recurring transactions + subscription surfacing  
3. [ ] Invoicing + PDF (if B2B-ish)  
4. [ ] Receipt OCR  
5. [ ] Bank feeds (highest compliance/cost — last unless mandatory)

---

## Non-negotiable gates (check before “MVP done”)

1. [ ] **Data model frozen** for household, membership, transactions, grocery entities.  
2. [ ] **Sync strategy accepted** (offline queue, conflicts, source of truth).  
3. [ ] **RTL/i18n** complete on all MVP screens.  
4. [ ] **Money rules** documented and tested (month, edits, deletes, exports).  
5. [ ] **Launch criteria** met (crash budget, core flows, privacy/support path).

---

## Dependencies (reminders)

- Grocery sync depends on **household membership** + stable client identity.  
- Reports depend on **consistent categories** + stable transaction history.  
- Grocery → expense depends on **transaction model** + permissions.

---

## Team shape (even if small)

- **Backend + sync + permissions**  
- **Mobile UI + RTL/i18n + grocery UX**  
- **PM / you:** weekly scope cuts, acceptance criteria, beta cohort  
- **Design (fractional):** mobile patterns + Hebrew typography/spacing

---

## How to use this file

1. At the start of each week, mark completed checkboxes and add **actual dates** next to milestones.  
2. When scope creeps, update **Phase 5** only; protect **Phases 0–4** for MVP.  
3. Paste your **stack and repo structure** at the bottom when known, for tighter week-by-week planning.

---

## Project facts (fill in)

| Field | Value |
|--------|--------|
| Repo / monorepo path | |
| Mobile stack (RN / Flutter / native / PWA) | |
| Backend (Firebase / custom / none yet) | |
| Target MVP date | |
| Beta testers | |
