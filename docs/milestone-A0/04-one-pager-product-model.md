# A0 — One-pager: journeys, entities, release target

---

## 1. Problem statement (one sentence)

Families running a small business need **one mobile place** to track **money** (business + household) and **groceries**, in **Hebrew and English**, with **shared access** across members.

---

## 2. Primary user journeys (MVP v1)

| # | Journey | Happy path | MVP acceptance (high level) |
|---|---------|------------|-----------------------------|
| J1 | **Onboard** | Install app → register → sign in | Email auth works; error messages understandable in active locale |
| J2 | **Create / enter workspace** | Create “family” workspace → see empty ledger | Workspace appears; defaults (categories, billing day) sensible |
| J3 | **Log spending** | Add expense → pick category → optional installments → save | Transaction visible in cycle; totals update live |
| J4 | **Log income** | Switch to income → add amount | Income tab lists entries; balance header reflects net |
| J5 | **Set category targets** | Targets tab → enter caps | Progress on expense tab reflects targets |
| J6 | **Collaborate** | Second member (same workspace) sees updates | Real-time sync; no data loss in normal use |
| J7 | **Grocery run** | Build list → check off in store → optionally log total as expense | List sync + expense shortcut (MVP scope) |
| J8 | **Switch language** | Settings → English / עברית | All MVP strings translated; RTL toggles correctly |

---

## 3. Core entities (conceptual + where stored today)

| Entity | Meaning | Storage today | Notes / gaps |
|--------|---------|----------------|--------------|
| **User** | Authenticated person | Firebase Auth user | Profile / display name minimal |
| **Workspace** | Household / “biz” container | `workspaces/{id}` | Members = emails; **no roles** |
| **Membership** | User belongs to workspace | `members` array | **Gap:** invite workflow not in UI |
| **Transaction** | Income or expense line | `workspaces/{id}/transactions/{txId}` | **Gap:** no business/personal flag yet |
| **Category** | Spending / income grouping | `customCategories` on workspace | Merged with defaults in UI |
| **Target** | Category cap (“budget lite”) | `targets.{category}` on workspace | Live-updated from UI |
| **Installment series** | Linked payments | same transactions + shared `groupId` | **Risk:** date math for future months should be QA’d |
| **Grocery list** | Shared shopping list | **Not in Firestore yet** | To be designed under `workspaces/{id}/...` |
| **Grocery item** | Row in a list | **N/A** | Fields: name, qty, unit, notes, checked, order |

---

## 4. Near-term release target (suggested)

| Milestone | Target outcome | Suggested horizon |
|-----------|----------------|-------------------|
| **Internal alpha** | Firebase rules + Hebrew/English + refactored structure (optional) | 2–4 weeks (calendar), depending on hours/week |
| **Household beta (2–5 families)** | Ledger + grocery + EN/HE + crash-free core flows on Android | +2–4 weeks after alpha |
| **Store-ready v1** | iOS parity, Crashlytics, privacy text, backups/exports | follow-on |

Dates are **not** committed here — fill in when you set your cadence.

---

## 5. Success metrics (MVP beta — lightweight)

- **Activation:** user completes first transaction within first session.  
- **Retention:** second session within 7 days for ≥50% of beta users (informal is fine).  
- **Collaboration:** ≥2 members on ≥1 workspace without support escalation.  
- **Quality:** no P0 data loss bugs; P1s triaged within 48h.

---

## 6. Open decisions (to resolve in M1 design, not blocking A0)

- Workspace identity: **email in `members`** vs **UID** (UID is more robust if email changes).  
- Grocery data model: subcollection vs root collection with `workspaceId` field (subcollection keeps rules simpler).  
- Whether **targets** remain workspace-level maps or move to a `settings` doc for fewer hot writes.
