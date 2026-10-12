def actions
  box
    form method: post
      choose
        when .path
          hidden path, .path
      choose
        when .return_to
          hidden return_to, .return_to
      children
