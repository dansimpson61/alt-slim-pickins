# alt-slim-pickins — roadmap 0.9

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **closed 2026-10-21.** Drafted 2026-10-21 by the steward for dan; passed Stretch Exam with 6 daytrips (0.9.0a to 0.9.0f).
It is a roadmap and not a plan: it names the question and what success looks
like, leaving the step-by-step work to daytrips, the way 0.4, 0.5, 0.6, 0.7,
and 0.8 did.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
>
> *Walk like the chameleon: what lies ahead is watched, what lies behind is
> glanced back at.*

## The question

> **Can the language carry an authentic, transactional database application —
> full Create, Read, Update, Delete lifecycles with SQLite persistence, relational
> mutations, server-side validation error handling with preserved form state,
> flash lifecycle feedback, and live quantitative recalculation — with the author
> writing zero JavaScript, zero `tag` escapes, zero bespoke CSS, and zero domain
> boilerplate?**

It is a forward-eye question, which is what an odd roadmap asks for (README,
*How roadmaps go*). It is the **Stretch Exam** from
[docs/STRETCH_PROTOCOL.md](docs/STRETCH_PROTOCOL.md), **Horizon A — The Authentic
CRUD & State-Mutation Benchmark** — selected and named at the close of 0.8.

The target is real: `examples/portfolio` is elevated from a two-view fixture
specimen into a living Wealth & Asset Allocation workbench backed by SQLite.

## The definition of success

The exam is passed when the paper drafted in Daytrip 0.9.0a renders live,
unmodified, and meets the **Dense Analytical & Transactional Workbench**
benchmark — not when a checker exits 0. A Stretch Exam passes on four
conditions (STRETCH_PROTOCOL, *Visual Sign-Off & Gate Lock*):

1. **The Wall Ledger empties.** Each wall identified during the paper run is
   healed at the structural layer of the language — never by making the author
   mind the compiler, and never by an app-space polyfill.
2. **The paper runs unmodified.** The `.frame`, `.sp`, `.layout`, and `.style`
   views drafted for `examples/portfolio` are the files the application serves.
3. **Green, and looked at.** All twelve gate legs and the suite green, and the
   live portfolio application inspected in the browser against the Dense
   Analytical & Transactional archetype:
   - Form inputs with clear validation feedback and preserved dirty state on 422.
   - Live metrics, tables, and totals dynamically recalculating across relational mutations.
   - Empty states co-existing with interactive creation workflows.
   - Flash alerts and confirmations that inform without interrupting.
4. **Authentic Persistence & State Transitions.** The app uses real SQLite
   transactions, persisting changes across process restarts and demonstrating
   idiomatic RESTful interaction with pure `.sp` markup.

## The Stretch Exam Benchmark: Portfolio Workbench

### 1. Relational Domain & Schema
A clean, minimal SQLite-backed relational model without external ORMs (pure Ruby structs + small persistence repository):
- **Accounts:** `id`, `name`, `institution`, `account_type` (`brokerage`, `roth_ira`, `traditional_ira`, `savings`), `created_at`.
- **Holdings:** `id`, `account_id`, `symbol`, `shares`, `cost_basis`, `current_price`, `updated_at`.
- **Transactions / Activities:** `id`, `account_id`, `holding_id`, `action` (`buy`, `sell`, `deposit`, `dividend`), `amount`, `shares`, `executed_at`.

### 2. Full Transactional Lifecycles
- **Account CRUD:**
  - Create Account (`/accounts/new`, `POST /accounts`) with validation (name required, valid institution).
  - Show Account (`GET /accounts/:id`) with its holdings, totals, allocation weights, and recent activity.
  - Edit Account (`GET /accounts/:id/edit`, `PATCH /accounts/:id`).
  - Archive/Close Account (`DELETE /accounts/:id`) with safe confirmation and cascade handling.
- **Holding Mutations:**
  - Buy/Add Holding (`GET /accounts/:id/holdings/new`, `POST /accounts/:id/holdings`) with shares > 0, price > 0.
  - Adjust/Sell Holding (`GET /holdings/:id/edit`, `PATCH /holdings/:id` or `POST /holdings/:id/transact`).
  - Delete/Liquidate Holding (`DELETE /holdings/:id`).
- **Live Net Worth & Metric Recalculation:**
  - Overall Portfolio Net Worth (`total_value`), YTD Return (`percent`), Unrealized Gain/Loss (`gain`), Annual Income (`money`).
  - Real-time recalculation of table totals, weights, and metrics upon every write.

### 3. The Front-of-Mind Walls to Measure (Daytrip 0.9.0a)

The Stretch Exam will inventory the exact walls, with these candidate seams
watched closely:

1. **Form Binding, Dirty Values & Method Overrides:**
   - How does `form` bind to a record or submitted params on validation failure?
   - How does a form express `method: patch` or `method: delete` without writing hidden inputs by hand?
   - How does `input` or `field` retain submitted values when re-rendering on 422?

2. **Validation Feedback & Error Diagnostics:**
   - How do validation errors present in `.sp`? Does `field` or `input` indicate invalid state (`aria-invalid`, class `is-invalid`)?
   - How does a form render an error summary or field-specific error notes without messy conditionals?

3. **Destructive Actions & Confirmations without JavaScript:**
   - How does an action or button express a destructive POST/DELETE action cleanly?
   - How do confirmations work in pure HTML/HTTP without `onclick="confirm(...)"`?

4. **Flash Messaging & Lifecycle Feedback:**
   - How does flash messaging (`flash[:notice]`, `flash[:alert]`) flow through the `.frame` or layout cleanly?
   - Can `.sp` render a flash alert with zero boilerplate?

5. **Collection-Scoped Emptiness with Active Creation Forms:**
   - Proved in 0.8.0f on specimen; now stressed in a real app where an empty account table sits beside an active "Add First Holding" form.

6. **Transactional Spatial Postures in `.layout`:**
   - Analytical workbench micro-layouts: split panes (master/detail, account list beside account holdings), action bars, responsive financial tables with sticky totals.
