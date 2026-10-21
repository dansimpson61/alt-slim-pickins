# Daytrip 0.9.0c — Form Method Override & Safe Destructive Deletions

**Date:** 2026-10-21  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (Phase 3 of 6, Healing Wall 1 & Wall 4)

## Premise & Measurement

1. **Wall 1 (Form RESTful Method Override):** Browsers only support HTTP `GET` and `POST` for HTML forms. When a `.sp` template declared `form method: patch` or `method: delete`, `Generator#form` previously emitted raw `method="patch"` or `method="delete"`, causing browsers to silently downgrade to `GET` and dropping the payload. Furthermore, because `.sp` syntax prohibits identifiers beginning with leading underscores (`_method`), authors could not write `hidden _method, "patch"` without a syntax error.
2. **Wall 4 (Safe Destructive Actions Without JavaScript):** Deleting entities in pure HTML requires either inline POST/DELETE forms or safe two-step confirmation screens. Without RESTful method overrides, destructive deletions could not be expressed safely without client-side `onclick` handlers or dangerous GET links.

## What Changed

1. **Automatic REST Method Override in `Generator#form`:**
   - In `lib/slim_pickins/generator.rb`:
     - Checks if `attrs[:method]` is `:patch`, `:put`, or `:delete`.
     - When true, renders HTML `method="post"` and automatically injects `<input type="hidden" name="_method" value="#{method}">` as the first child of the `<form>` element.
     - Detects if an explicit `hidden` node for `_method` was already provided, preventing duplicate inputs.
   - Added unit test `test_form_method_override_injects_hidden_method_field` in `test/vocabulary_partials_test.rb`.

2. **Implemented Safe Two-Step Confirmation in `examples/portfolio`:**
   - In `examples/portfolio/views/confirm_close.sp`:
     - Created a clean confirmation view with `card`, `title`, warning text, and `<form to: "/accounts/#{account.id}", method: delete>` enclosing `button danger, "Yes, Close Account"`.
   - In `examples/portfolio/views/account.sp`:
     - Added `link close, "Close account", to: "/accounts/#{account.id}/close"` inside `card > actions`.
   - In `examples/portfolio/app.rb`:
     - Enabled `method_override: true` in Sinatra.
     - Connected `get '/accounts/:id/close'` and `delete '/accounts/:id'` calling `repo.delete_account`.

3. **Census & Verified Pages Growth:**
   - Added `confirm_close.sp` to `StudioPages::PAGES` and `bin/verify_pages.rb`.
   - Incremented census verified pages from 30 to 31 across `HANDOFF.md`, `PROJECT.md`, `README.md`, and `docs/PRIMER.md`.
   - Added `Portfolio.set :environment, :test` to `test/phase6_test.rb` to preserve Phase 6 integration expectations while enabling the SQLite repository in development.

## Verification

- All 12 gate legs: **0 problems** (12/12 PASS).
- 31 verified pages: **0 problems** (`bin/verify_pages.rb`).
- Full test suite: **651 runs, 6,974 assertions, 0 failures, 0 errors, 0 skips**.
