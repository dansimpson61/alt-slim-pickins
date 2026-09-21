card
  title .prompt
  choose
    when .correct
      badge ok, "Correct"
    otherwise
      badge error, "Incorrect"
  fact user_answer, .user_answer
  fact correct_answer, .correct_answer
  note .explanation
