page "Doc Reader"
  catalog docs, "Documents"
  reading_pane selected_doc

def catalog, documents, title
  box documents, title
    empty "No markdown documents in ~/dev/alt-slim-pickins."
    list
      each document
        link .name, .path

def reading_pane, document
  box document, .name
    empty "No document selected."
    prose markdown, .content
