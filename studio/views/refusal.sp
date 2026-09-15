# The refusal page: what a playground error renders as. The complaint speaks
# the language's own voice — path, line, sentence — and the fence shows the
# sentence that hit it, when the error knows one (a JSON parse error names
# no sentence, so its rows stay absent by construction).

page .title
  stylesheet "/assets/slim-pickins.css"
  note error, .complaint
  choose
    when .where
      note quiet, .where
  choose
    when .line
      snippet sp, .line
