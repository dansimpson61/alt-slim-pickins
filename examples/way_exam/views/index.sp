"The Way Exam"
  card
    title "Examination of the Way"
    text "Answer the questions below to test your mastery of the Slim-Pickins Way as documented in PRIMER.md and the Ode to Joy."
    section overview, "Exam Standards"
      grid metrics, columns: 2
        metric questions_count, "Total Questions"
        metric passing_score, "Passing Score"

  form to: "/grade", method: post
    each question
      group .title
        text .prompt
        choice radio, .id
          option a, .option_a
          option b, .option_b
          option c, .option_c
    actions
      button "Submit Exam for Grading"
