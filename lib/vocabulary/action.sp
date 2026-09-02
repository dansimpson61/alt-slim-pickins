# content: true
# modifiers: to path return_to variant
# shape: encloses

form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
