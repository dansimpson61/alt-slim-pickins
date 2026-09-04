page "Slim-Pickins Studio"
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    sidebar
      heading "Vocabulary"
      link "iframe", to: "/docs/iframe"
      link "split_pane", to: "/docs/split_pane"
      link "sidebar", to: "/docs/sidebar"

    split_pane
      tag section, class: "studio-editor"
        heading "Write .sp Code"
        form to: "/render", method: "post", target: "preview"
          textarea source
          button "Render"
          
      tag section, class: "studio-preview"
        heading "Output"
        tag iframe, name: "preview", class: "w-full h-full border"
