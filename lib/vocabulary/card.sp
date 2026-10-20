def card target, title, variant:
  box .variant, id: .id
    choose
      when .title
        heading .title
    contents
