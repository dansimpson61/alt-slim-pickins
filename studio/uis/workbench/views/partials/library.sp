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
    tab "Pages"
      list
        each entry, from: .palette
          item
            link_to .name, path: .load_path, id: .id, active: .here
            badge .status
            prose plain, .refusal, if: .refusal
    tab "Words"
      list
        each word
          item
            link_to .name, to: word, word: .name
    tab "Guides"
      list
        each guide
          item
            link_to .name, to: guide, name: .name
  ui_picker
