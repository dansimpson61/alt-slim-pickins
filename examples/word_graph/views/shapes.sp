"Structural Shapes"
  card
    title "Structural Shapes of alt-slim-pickins"
    paragraph "The 63 words of alt-slim-pickins partition into exactly 7 structural shapes: encloses (20), presents (17), says (9), registers (8), document (3), gathers (5), and iterates (1)."

  section "Shape Distribution Chart"
    chart shapes, over: name
      line count

  section "The Seven Shapes"
    grid cards, columns: 2
      each shape, from: .shapes
        card
          title .name
          badge neutral, .count
          paragraph .description
          actions
            link "View Words", to: "/?shape=#{shape.shape}"

  actions
    link "Back to Word Graph", to: "/"
