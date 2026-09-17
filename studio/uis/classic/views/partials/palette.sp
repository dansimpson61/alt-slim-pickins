# The repo's own pages, each with the verdict the census gave it when this
# page was built — the render you get when you load it, payload and all
# (2026-09-17). `ok` says it renders; `error` names the wall it hit, recorded
# verbatim the way the language said it. Loading one fills the editor, so the
# refusals that remain are the demand ledger the next studio rounds pick from.
#
# The refusal is guarded with `if:` rather than rendered empty: an `ok` entry
# has no complaint to show, and a blank paragraph per entry is noise.
#
# The load path is minted by the UI's own `paths`, never written here: the
# whole point of several UIs is that a click in one cannot land in another.

box
  section "Start from a real page"
    list
      each entry, from: .palette
        item
          link_to .name, path: .load_path, id: .id, active: .here
          badge .status
          prose plain, .refusal, if: .refusal
