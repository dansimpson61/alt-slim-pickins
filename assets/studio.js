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
      const { visual, source, inspect, definitions } = await response.json()
      if (this.visual()) this.visual().srcdoc = visual
      if (this.source()) this.source().srcdoc = source
      if (this.inspect() && inspect) this.inspect().srcdoc = inspect
      this.updateDefinitions(definitions)
    } catch (error) {
      if (this.visual()) this.visual().srcdoc = `<p style="color:red;padding:1rem">The studio did not answer: ${error}</p>`
    }
  }

  updateDefinitions(definitions) {
    let bar = this.element.querySelector('.mint-bar')
    if (!definitions || definitions.length === 0) {
      if (bar) bar.remove()
      return
    }

    if (!bar) {
      bar = document.createElement('div')
      bar.className = 'mint-bar'
      bar.style.cssText = 'display:flex;flex-wrap:wrap;gap:0.5rem;align-items:center;padding:0.4rem 0.6rem;margin-bottom:0.5rem;background:var(--surface-soft,#f3f1eb);border:1px solid var(--rule,#e5e1d8);border-radius:var(--radius,4px);font-size:var(--size-small,0.875rem);'
      const sourceField = this.element.querySelector('textarea[name="source"]')
      if (sourceField) {
        sourceField.parentNode.insertBefore(bar, sourceField)
      } else {
        this.element.prepend(bar)
      }
    }

    bar.innerHTML = '<span style="color:var(--ink-soft,#525b68);font-weight:600;">In-buffer:</span>'
    definitions.forEach(def => {
      const btn = document.createElement('button')
      btn.type = 'button'
      btn.style.cssText = 'background:var(--surface,#fff);border:1px solid var(--rule,#e5e1d8);border-radius:var(--radius,4px);padding:0.25rem 0.5rem;cursor:pointer;font-family:var(--face-mono,monospace);font-size:0.8rem;color:var(--ink,#1f2430);'
      const paramsList = def.params && def.params.length ? `(${def.params.join(', ')})` : ''
      btn.textContent = `Mint ${def.word}${paramsList} → partial`
      btn.title = `Promote ${def.word} to a standalone app partial on disk`
      btn.addEventListener('click', () => this.mintWord(def.word, btn))
      bar.appendChild(btn)
    })
  }

  async mintWord(word, btn) {
    const sourceTextarea = this.element.querySelector('textarea[name="source"]')
    if (!sourceTextarea) return

    btn.disabled = true
    btn.textContent = `Minting ${word}...`

    try {
      const res = await fetch('/mint', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ word: word, source: sourceTextarea.value })
      })
      const result = await res.json()
      if (result.ok) {
        btn.textContent = `Minted to ${result.path}!`
        btn.style.borderColor = 'var(--positive, #047857)'
        btn.style.color = 'var(--positive, #047857)'
        sourceTextarea.value = result.remaining_source
        setTimeout(() => this.render(), 600)
      } else {
        btn.textContent = `Error: ${result.error || 'Failed'}`
        btn.disabled = false
      }
    } catch (err) {
      btn.textContent = `Error: ${err}`
      btn.disabled = false
    }
  }

  visual() { return document.getElementsByName('preview')[0] }
  source() { return document.getElementsByName('html_preview')[0] }
  inspect() { return document.getElementsByName('inspect_preview')[0] }
}

Stimulus.Application.start().register('render', RenderController)
