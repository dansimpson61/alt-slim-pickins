def action label, to:, variant:, status:
  choose
    when .status
      button .variant, .label, to: .to, name: status, value: .status
    otherwise
      button .variant, .label, to: .to
