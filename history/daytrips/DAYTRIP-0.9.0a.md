# Daytrip 0.9.0a — The Portfolio Workbench, on paper (the Stretch Exam's first movement)

**Status: complete.** Roadmap 0.9's opening movement: the Authentic CRUD &
State-Mutation Stretch Exam drafted on paper, uncompromised, then held against
the current language to inventory the Wall Ledger.

## Objective

Draft the persistent, transactional SQLite-backed Portfolio Workbench the way an
author wishes to write it — a clean `.frame`, route `.sp` views of pure substance,
a `.layout` that carries the analytical posture, and a `.style` layer for the
workbench palette — with zero client-side JavaScript, zero `tag` escapes, zero
bespoke CSS, and zero domain DTO boilerplate. Then run that paper against the
current compiler and runtime, recording every pinch as the Wall Ledger that
Roadmap 0.9 will spend itself on.

---

## Movement 1 — Paper First: The Uncompromised Workbench

**Archetype: Dense Analytical & Transactional Workbench** (declared per
`docs/STRETCH_PROTOCOL.md`). Where Roadmap 0.7's *Editorial Prose* benchmark
demanded bounded columns and quiet margins, the *Dense Analytical Workbench*
demands:
- High-density financial data: multi-column tabular listings, right-aligned
  numerics, totals, and compact metric grids.
- Authentic state mutation: creating accounts, buying/selling holdings, and
  recording cash contributions.
- Server-side validation diagnostics (`422 Unprocessable Entity`): error
  annotations on invalid fields while preserving dirty submitted values.
- Direct feedback: flash notifications on state changes and safe confirmation
  postures for destructive deletions.

### The Frame — `views/portfolio.frame`

The frame provides outer shell chrome, top navigation, flash alerts, and
footer:

```frame
nav
  link home, "Overview", to: "/"
  link new_account, "Open Account", to: "/accounts/new"
flash
contents
footer "Portfolio Workbench · SQLite-backed persistence · 100% pure Ruby & semantic .sp"
```

### 1. The Overview Page — `views/index.sp`

```sp
portfolio, "Your Portfolio"
  section "Where you stand"
    grid metrics, columns: 4
      metric total_value, as: money
      metric gain, "Total Gain", as: money
      metric ytd_return, "YTD Return", as: percent
      metric annual_income, "Projected Income", as: money
  section accounts, "Your Accounts"
    empty "No accounts opened yet. Start your portfolio by opening a retirement, brokerage, or cash account."
    actions
      link open, "Open New Account", to: "/accounts/new"
    each account
      card
        actions
          link show, "Manage Account", to: "/accounts/#{account.id}"
```

### 2. The New Account Page — `views/new_account.sp`

```sp
"Open New Account"
  form account, to: "/accounts"
    choose
      when .errors?
        note alert, "Please correct the errors below."
    field name, placeholder: "e.g. Vanguard Brokerage", required: true
    field institution, placeholder: "e.g. Vanguard", required: true
    choice account_type, "Account Type"
      option "brokerage", "Taxable Brokerage"
      option "roth_ira", "Roth IRA"
      option "traditional_ira", "Traditional IRA"
      option "savings", "High-Yield Savings"
    actions
      button "Open Account"
      link cancel, "Cancel", to: "/"
```

### 3. The Account Detail Page — `views/account.sp`

```sp
account, .name
  section meta
    badge .account_type
    metric institution, "Institution"
    metric cash_balance, "Cash Available", as: money
    metric total_value, "Account Value", as: money
  section holdings, "Holdings"
    empty "No holdings in this account yet. Record your first asset below."
    table
      column symbol
      column shares, as: number
      column cost_basis, "Cost / Share", as: money
      column market_value, "Value", as: money
      column gain, as: money
      column weight, as: percent
      total market_value, "Account Total"
  actions
    link add_holding, "Record Holding", to: "/accounts/#{account.id}/holdings/new"
    link edit_account, "Edit Account", to: "/accounts/#{account.id}/edit"
    link close_account, "Close Account", to: "/accounts/#{account.id}/close"
```

### 4. The Edit Account Page — `views/edit_account.sp`

```sp
account, "Edit #{account.name}"
  form account, to: "/accounts/#{account.id}", method: patch
    choose
      when .errors?
        note alert, "Please correct the errors below."
    field name, required: true
    field institution, required: true
    choice account_type, "Account Type"
      option "brokerage", "Taxable Brokerage"
      option "roth_ira", "Roth IRA"
      option "traditional_ira", "Traditional IRA"
      option "savings", "High-Yield Savings"
    actions
      button "Save Changes"
      link cancel, "Cancel", to: "/accounts/#{account.id}"
```

### 5. The Confirm Close Account Page — `views/confirm_close.sp`

```sp
account, "Close #{account.name}"
  card
    title "Are you sure you want to close this account?"
    text "Closing this account will liquidate all holdings and remove the account record. This action cannot be undone."
    form to: "/accounts/#{account.id}", method: delete
      actions
        button danger, "Yes, Close Account"
        link cancel, "Never mind", to: "/accounts/#{account.id}"
```

### 6. The Add Holding Page — `views/new_holding.sp`

```sp
holding, "Record Holding in #{account.name}"
  form holding, to: "/accounts/#{account.id}/holdings"
    choose
      when .errors?
        note alert, "Please correct the errors below."
    field symbol, placeholder: "e.g. VTI", required: true
    field shares, placeholder: "10", type: number, step: "any", required: true
    field cost_basis, "Purchase Price per Share", placeholder: "250.00", type: number, step: "0.01", required: true
    actions
      button "Record Holding"
      link cancel, "Cancel", to: "/accounts/#{account.id}"
```

---

## Movement 2 — Empirical Probes & The Wall Inventory

We measured each sentence from the paper views against the current compiler and
runtime to locate where the language pinches:

### Probe 1 — Form RESTful Method Override (`method: patch` / `method: delete`)

```ruby
sp = %q{
form account, to: "/accounts/1", method: patch
  field name
  button "Save"
}
SlimPickins.render(sp, locals: { account: { name: "Retirement" } })
```

**Measured Output:**
```html
<form class="form" id="account" action="/accounts/1" method="patch">
  <div class="field"><label for="name">Name</label><input id="name" name="name" type="text" value="Retirement"></div>
  <button type="submit" class="button">Save</button>
</form>
```

**The Pinch:** Standard web browsers do not support `method="patch"` or
`method="delete"`; they silently fall back to `GET` requests, breaking the
server endpoint! In Rack/Sinatra/Rails, non-GET/POST forms must render
`method="post"` and contain `<input type="hidden" name="_method" value="patch">`.

---

### Probe 2 — Field Validation Error Diagnostics

```ruby
sp = %q{
form account, to: "/accounts/1"
  field name, error: "cannot be blank"
}
SlimPickins.render(sp, locals: { account: { name: "" } })
```

**Measured Output:**
```text
SlimPickins::SyntaxError: `field` has no `error:` modifier
  page.sp, line 3
    field name, error: "cannot be blank"
```

**The Pinch:** `Field` and `Input` reject error modifiers. Furthermore, when
re-rendering a 422 validation failure with a dirty model that exposes
`account.errors[:name]`, `KeyValue.for_control` has no concept of errors, and
`Generator#field` cannot emit `.field--invalid`, `aria-invalid="true"`, or a
`<span class="field-error">` diagnostic message.

---

### Probe 3 — Flash Lifecycle in Frame & Empty Presence

```ruby
# In views.frame:
flash
contents
```

**Measured Output (when flash is absent or nil):**
```html
<p class="flash"></p>
<p class="text">Hello</p>
```

**The Pinch:** `lib/vocabulary/flash.sp` is defined as `def flash text / note .text`.
When invoked as bare `flash` in a `.frame`, it evaluates with `text = nil` and
unconditionally emits an empty `<p class="flash"></p>` element on every single
rendered page. When a flash notice *is* present in session or locals (e.g.,
`flash: "Account created."`), bare `flash` fails to bind it.

---

### Probe 4 — Destructive Actions & Confirmation Flows

```ruby
sp = %q{
actions
  button danger, "Close Account", to: "/accounts/1", method: delete
}
SlimPickins.render(sp)
```

**Measured Output:**
```text
SlimPickins::SyntaxError: `button` has no `method:` modifier
  page.sp, line 3
    button danger, "Close Account", to: "/accounts/1", method: delete
```

**The Pinch:** Standalone buttons cannot trigger HTTP DELETE actions without
custom JavaScript. Wrapping in `<form method: delete>` hits Probe 1 (browser
falls back to GET). The language needs clean RESTful form method overrides and
first-class two-step confirmation patterns.

---

## Movement 3 — The Wall Ledger

From these measurements, the Wall Ledger for Roadmap 0.9 is established:

| Wall | Description | Archetype Ceiling / Pinch |
| :--- | :--- | :--- |
| **Wall 1: Form Method Override (`_method`)** | `Form` renders raw `method="patch"` / `method="delete"`, causing browsers to issue GET requests. | Breaks transactional updates and deletions without custom JavaScript. Must emit `method="post"` and `<input type="hidden" name="_method" value="...">`. |
| **Wall 2: Field Validation Diagnostics & 422** | `Field` rejects `error:` modifier; no awareness of `subject.errors`; no invalid styling or accessible error text. | Prevents feedback on validation failures. Must support `error:`, infer errors from domain models, and emit `.field--invalid`, `aria-invalid`, and error spans. |
| **Wall 3: Flash Lifecycle & Presence** | `flash` emits an empty `<p class="flash"></p>` when absent; does not bind session/local flash messages. | Clutters the page chrome. Must cleanly disappear when empty and bind notices/alerts when present. |
| **Wall 4: Destructive Action & Confirmation Semantics** | Standalone buttons cannot issue DELETE; confirmation requires pure HTML flows. | Prevents safe deletion workflows. Solved by Wall 1 form overrides and idiomatic two-step confirmation views (`confirm_close.sp`). |
| **Wall 5: Analytical Workbench Spatial Posture** | `.layout` and `.style` companion for high-density financial tables, split panes, and metric headers. | The portfolio requires compact numeric tabular styling, right-aligned monetary values, sticky totals, and alert notes. |

---

## The Daytrip Plan for Roadmap 0.9

1. **Daytrip 0.9.0b — SQLite Domain & Persistence in Portfolio:**
   Build the authentic SQLite database schema, pure Ruby domain structs
   (`Account`, `Holding`, `Transaction`), and transactional repository with
   automatic recalculation of metrics, allocation weights, and income.
2. **Daytrip 0.9.0c — Wall 1 & Wall 4 (Form Method Override `_method` & Safe Deletions):**
   Heal `Form` to handle `method: :patch`, `:put`, `:delete` by rendering
   `method="post"` with hidden `_method` inputs, enabling pure HTML RESTful
   updates and deletions.
3. **Daytrip 0.9.0d — Wall 2 (Field Validation Diagnostics & 422 Re-rendering):**
   Heal `Field` and `Input` with `error:` support and `subject.errors`
   inference, emitting `.field--invalid`, `aria-invalid="true"`, and `<span
   class="field-error">`.
4. **Daytrip 0.9.0e — Wall 3 (Flash Lifecycle & Empty State Presence):**
   Heal `flash` so it binds flash messages when present and renders zero
   elements when absent.
5. **Daytrip 0.9.0f — Wall 5 & Visual Sign-Off (Workbench `.layout`, `.style`, Live Inspection, and Roadmap 0.9 Close):**
   Craft the `.layout` and `.style` companions for `portfolio`, verify all gate
   legs and pages, inspect the live CRUD application in the browser, and close
   Roadmap 0.9.
