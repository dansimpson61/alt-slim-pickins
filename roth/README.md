# roth

Notes about **`~/dev/roth`**, which is a separate, dormant project. Nothing here
describes this repo.

roth was ported in 0.1's Phases 7 and 8 — the working port lives in
[../examples/roth](../examples/roth), and it requires roth's engine off disk
without modifying it. Reading that engine closely produced two documents worth
keeping apart from this project's own:

- **[ROTH_STUDY.md](ROTH_STUDY.md)** — what a close reading found, on two axes:
  architecture and retirement-planning domain knowledge. Every claim measured by
  running the code. The headline: one missing `require 'ostruct'` meant the spec
  suite could never run, which let a rename be abandoned halfway in September
  2025, which is why the live app silently drops Social Security.
- **[ROTH_DOMAIN_BACKLOG.md](ROTH_DOMAIN_BACKLOG.md)** — the same findings as a
  runnable project brief: eight defects that are simply wrong, eleven questions
  that are dan's, and the one `require` that has to come first.

**Both are roth's work, not this project's.** They are here because this is
where the reading happened, and they should move to `~/dev/roth` if that project
ever wakes up.

`~/dev/roth` has not been modified by any of this. Its working tree has been
mid-rename since 2025-09-11, and `examples/roth/lib/engine.rb` raises with an
explanation if that rename is reverted rather than finished.
