expects variant, takes: content, children: any, takes: id, shape: encloses, infers: card_id, infers: box_tag, infers: box_depth


box .name, id: .id
  choose
    when .content
      heading .content
  children
