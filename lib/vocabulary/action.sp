def action, label
  choose
    when .status
      button .variant, .label, to: .to, name: status, value: .status
    otherwise
      button .variant, .label, to: .to
