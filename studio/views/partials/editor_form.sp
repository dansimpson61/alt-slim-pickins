form to: "/render", method: "post", target: "preview"
  textarea source, rows: 4, required: true
  button "Render Visual", type: "submit"
  button "Render HTML", type: "submit", to: "/render_html", target: "html_preview"
  # Note: A single form can only target one iframe per submission natively.
  # Future Stimulus.js integration will intercept the post and update multiple iframes simultaneously.
