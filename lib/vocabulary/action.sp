expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true, status: true

form method: post, to: .to
  choose
    when .path
      hidden path, .path
  choose
    when .return_to
      hidden return_to, .return_to
  choose
    when .status
      hidden status, .status
  button .variant, .content
