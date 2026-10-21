card
  title .word_name
  dictionary .speech
    on verb
      badge warning, "Control Flow"
    otherwise
      dictionary .shape
        on gathers
          badge ok, "Gatherer"
        on registers
          badge neutral, "Register"
        otherwise
          badge neutral, .shape_name
  grid metrics, columns: 3
    metric connections_count, "Connections", as: number
    metric in_degree, "Parents", as: number
    metric out_degree, "Children", as: number
  fact speech_name
  fact subject_name
  fact parents_summary
  fact children_summary
  fact conventions_summary
  actions
    link "Inspect Word", to: "/words/#{word.word_name}"
