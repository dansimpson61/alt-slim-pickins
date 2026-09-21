page "Exam Results"
  section result, "Score & Verdict"
    card
      choose
        when .passed
          badge ok, .verdict
        otherwise
          badge warning, .verdict
      grid metrics, columns: 3
        metric score, "Correct Answers"
        metric total, "Total Questions"
        metric percentage, "Score Percentage"
  section reviews, "Question Review"
    each review
      question_card
  actions
    link retake, "Retake Exam", to: "/"
