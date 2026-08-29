# alt-slim-pickins — lore

What working sessions *learned* here — not what they did. Appended by
agents and humans; read back by the project card and `/brief`.

## 2026-08-29 — Claude Opus 5

Slim's grammar splits cleanly in two, and the split is the design opportunity. The line skeleton is genuinely one sentence (indentation + one leader from a closed set + the rest; indented lines are children) and holds everywhere. All the irregularity lives in the tag line. Verified against Slim 5.2.1: (1) attribute values are undelimited Ruby terminating at whitespace, so `a href=1+2` yields href=3 but `a href=1 + 2` silently yields href=1 with `+ 2` as text content — no error; (2) `:` is a second nesting mechanism competing with indentation and colliding with embedded-engine syntax — `li: a Home` works, `li:` with an indented block is a SyntaxError; (3) whitespace control is a suffix sublanguage (`p<`, `p>`, `p<>`, `=<`, `==<>`); (4) escaping is encoded by character doubling (`=` escapes, `==` does not). Keep the skeleton; the tag line is what needs redesigning.
