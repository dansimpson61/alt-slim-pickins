page .archive_heading
  text "Moves the project into archive/ — nothing is deleted, and it can be un-archived."
  form method: post, to: "/actions/archive"
    hidden path, .archive_path
    hidden confirmed, "1"
    hidden return_to, .archive_return_to
    textarea reason, "Why archive this copy?", rows: 2, required: true
    button primary, "Confirm archive"
  link home, "Cancel", to: .archive_return_to
