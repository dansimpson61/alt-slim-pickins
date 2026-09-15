page "Slim-Pickins Studio"
  stylesheet "/assets/slim-pickins.css"
  script "/assets/stimulus.umd.js"
  script "/assets/studio_controller.js"
  sidebar_layout
    vocabulary
    split_pane
      editor
      tabs
        tab "Visual", active: true
          preview
        tab "HTML"
          html_preview
