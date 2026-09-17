aside
  group "UI"
    list
      each entry, from: .ui_names
        item
          link_to .title, to: switch, name: .name, active: .current
