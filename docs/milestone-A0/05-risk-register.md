# A0 — Risk register

**How to use:** Assign **Owner** (name), **Status** (`open` / `mitigating` / `closed`), and **Next action** per row. Review weekly during MVP.

| ID | Risk | Category | Likelihood | Impact | Mitigation | Owner |
|----|------|----------|-------------|--------|------------|-------|
| R1 | **Firestore rules missing or too permissive** exposes all workspaces | Security | High if rules default | Critical | Write least-privilege rules; version in repo; test with non-admin account | TBD |
| R2 | **Client-only enforcement** — any determined user could bypass UI | Security | Med | High | Rules must enforce `members` + field validation; consider UID-based membership | TBD |
| R3 | **Email as membership key** — email change breaks access | Product / data | Med | Med | Migrate to `uid` + optional `email` display | TBD |
| R4 | **Monolithic `main.dart`** slows delivery and increases regression risk | Engineering | High | Med | Introduce folders / repositories; screen-per-file refactor in M1–M2 | TBD |
| R5 | **Hebrew-only codebase** blocks EN/HE product goal | Product | High today | High | ARB + `gen-l10n`; remove forced `locale` | TBD |
| R6 | **Installment date logic** (`month + i`) may hit invalid calendar days | Correctness | Med | Med | Unit tests around month boundaries; use safe date APIs | TBD |
| R7 | **No crash reporting** — blind to production failures | Ops | High | Med | Add Crashlytics or Sentry before wide beta | TBD |
| R8 | **No automated CI** — regressions slip in | Quality | Med | Med | GitHub Actions: `flutter analyze`, `flutter test` | TBD |
| R9 | **Unused dependencies** (`gsheets`, `shared_preferences`, `path_provider`) | Maintenance | Low | Low | Remove or implement; run `dart pub deps` | TBD |
| R10 | **No explicit offline UX** — user thinks data saved when it did not | UX / trust | Med | High | Show sync state / retry; document Firestore offline behavior | TBD |
| R11 | **Grocery + finance concurrency** — unclear conflict rules | Product | Med | Med | Define LWW or field-level merge; activity log optional | TBD |
| R12 | **Privacy / GDPR-style requests** not defined | Legal / trust | Low until scale | Med | Document retention + deletion; Firebase export story | TBD |

---

## Near-term actions (recommended order)

1. **R1 / R2:** Draft Firestore rules + test matrix (highest priority before non-dev users).  
2. **R5:** String externalization + English ARB.  
3. **R4:** Structural refactor as soon as grocery module starts (avoid bigger bang later).  
4. **R7 / R8:** Observability + CI in parallel once core flows stabilize.
