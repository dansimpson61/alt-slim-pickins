expects children: any, takes: path, takes: return_to, shape: encloses, infers: partial_slot_forwarding

box
  form method: post
    choose
      when .path
        hidden path, .path
    choose
      when .return_to
        hidden return_to, .return_to
    children
