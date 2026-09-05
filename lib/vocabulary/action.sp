expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true


form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
