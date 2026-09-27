nav
  link home, "~/dev", to: "/"
  link studio, to: "/", active: nav_state.studio
  link library, to: "/library", active: nav_state.library
  link reconcile, to: "/reconcile", active: nav_state.reconcile
  link dispatch, to: "/dispatch", active: nav_state.dispatch
  link ports, to: "/ports", active: nav_state.ports
  search placeholder: "search…", q: .q
choose
  when .error_entry
    disclosure error_entry.project
      snippet error_entry.log
      link home, "Open Project Card", to: error_entry.href
contents
