entry
  meta
    time .date
    badge .author
    metric reading_minutes, "Minutes"
  prose markdown, .body
  section words, "Words mentioned"
    empty "No words indexed in this entry."
    chips
      each word
        badge .to_s

def meta
  box
    contents

def chips
  box
    contents
