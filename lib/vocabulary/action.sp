expects takes: content, shape: encloses, takes: to, takes: path, takes: return_to, takes: variant, takes: status

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
