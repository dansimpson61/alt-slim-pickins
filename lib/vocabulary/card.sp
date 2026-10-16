def card target, title
  box .variant, id: .id
    choose
      when .title
        heading .title
    contents
