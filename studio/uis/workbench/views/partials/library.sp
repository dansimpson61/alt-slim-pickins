# The shelf: everything a page can draw on, in one place.
#
# Three kinds of thing, browsed the same way — the language's words, the
# repo's real pages with their census verdict, and the documents. The
# state of the shelf (what you picked, and its refusal if it has one) is set
# by whichever page is being served, so `/docs/:word` shows the word's own
# docs here rather than on a page of their own.
box
  search placeholder: "Search the library"
  fact words, .words_count
  fact pages, .pages_count
  tabs
    tab "Pages", active: .pages_active
      list
        each entry, from: .palette
          item
            link_to .name, path: .load_path, id: .id, active: .here
            badge .status
            prose plain, .refusal, if: .refusal
    tab "Words", active: .words_active
      each tier, from: .vocabulary_tiers
        group .title
          note quiet, .question
          list
            each word, from: .words
              item
                link_to .name, to: word, word: .name, active: .active
                badge neutral, .badge, if: .badge
    tab "Guides", active: .guides_active
      list
        each guide
          item
            link_to .name, to: guide, name: .name
  ui_picker
