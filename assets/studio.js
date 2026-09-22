/*
 * The studio's render seam — the burr's resolution (2026-09-15).
 *
 * Vendored beside this file: stimulus.umd.js, the UMD distribution of
 * @hotwired/stimulus@3.2.2 (MIT, Basecamp); the bundle's own banner says
 * 3.2.1, which is the banner the 3.2.2 package ships. No build step, by
 * design — the studio has none and keeps having none.
 *
 * One controller, one contract: the form posts once, the response
 * { visual, source } lands in both iframes — found by the names the
 * language already emits. Rendering is live: debounced on input, and once
 * on connect, so a seeded page appears the moment the page loads. No
 * Render button remains (dan's ruling, 2026-09-15): live rendering made
 * it redundant, and the studio says so rather than hiding it — rendering
 * requires JavaScript.
 */
class RenderController extends Stimulus.Controller {
  static values = { debounce: { type: Number, default: 300 } }

  connect() {
    this.timeout = null
    this.render()
  }

  input() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.render(), this.debounceValue)
  }

  submit(event) {
    event.preventDefault()
    clearTimeout(this.timeout)
    this.render()
  }

  async render() {
    const body = new URLSearchParams(new FormData(this.element))
    try {
      const response = await fetch('/render.json', { method: 'POST', body })
      const { visual, source, inspect } = await response.json()
      if (this.visual()) this.visual().srcdoc = visual
      if (this.source()) this.source().srcdoc = source
      if (this.inspect() && inspect) this.inspect().srcdoc = inspect
    } catch (error) {
      if (this.visual()) this.visual().srcdoc = `<p style="color:red;padding:1rem">The studio did not answer: ${error}</p>`
    }
  }

  visual() { return document.getElementsByName('preview')[0] }
  source() { return document.getElementsByName('html_preview')[0] }
  inspect() { return document.getElementsByName('inspect_preview')[0] }
}

Stimulus.Application.start().register('render', RenderController)
