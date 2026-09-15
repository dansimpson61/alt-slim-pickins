# The repo's own pages, each with the verdict the census gave it when this
# page was built: `ok` says the page renders with the playground's locals,
# `error` names the wall it hit, and the refusal is recorded verbatim the
# way the language said it. Loading one fills the editor; the refusals are
# the demand ledger the next studio rounds pick from.

box
  section "Start from a real page"
    list
      each entry, from: .palette
        item
          link .name, to: .load_path, active: .here
          badge .status
          prose plain, .refusal
