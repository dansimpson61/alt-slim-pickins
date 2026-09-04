page "Slim-Pickins Studio"
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    sidebar
      heading "Vocabulary"
      link "iframe", to: "/docs/iframe"
      link "split_pane", to: "/docs/split_pane"
      link "sidebar", to: "/docs/sidebar"

    split_pane
      region class: "studio-editor"
        heading "Write .sp Code"
        form to: "/render", method: "post", target: "preview"
          textarea source
          button "Render"
          
      region class: "studio-preview"
        heading "Output"
        iframe name: "preview", class: "w-full h-full border"
