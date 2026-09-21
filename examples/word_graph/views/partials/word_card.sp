card
  title .word_name
  choose
    when .is_gatherer
      badge ok, "Gatherer"
    when .is_register
      badge neutral, "Register"
    when .is_control
      badge warning, "Control Flow"
    otherwise
      badge neutral, .shape_name
  grid metrics, columns: 3
    metric connections_count, "Connections"
    metric in_degree, "Parents"
    metric out_degree, "Children"
  fact speech_name
  fact subject_name
  fact parents_summary
  fact children_summary
  fact conventions_summary
  actions
    link "Inspect Word", to: "/words/#{word.word_name}"
