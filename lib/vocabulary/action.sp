expects takes: content, shape: encloses, takes: to, takes: path, takes: return_to, takes: variant, takes: status

choose
  when .status
    button .variant, .content, to: .to, name: status, value: .status
  otherwise
    button .variant, .content, to: .to

