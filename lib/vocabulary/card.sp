def card, subject, content
  box .variant, id: .id
    choose
      when .content
        heading .content
    contents
