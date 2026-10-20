def search q:, placeholder:, to:
  choose
    when .to
      form method: get, to: .to
        input q, .q, placeholder: .placeholder
    otherwise
      form method: get, to: "/search"
        input q, .q, placeholder: .placeholder
