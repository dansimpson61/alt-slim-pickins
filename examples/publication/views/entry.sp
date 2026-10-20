entry
  meta
    time .date
    badge .author
    metric reading_minutes
  prose markdown, .body
  section words, "Words mentioned"
    empty "No words indexed in this entry."
    chips
      each word
        badge .to_s

def meta
  box

def chips
  box
