# frozen_string_literal: true

require_relative '../../../lib/slim_pickins'

# The dashboard's own words, ported. The dashboard's design system speaks
# sp-* classes; the vocabulary's words carry alt's own design system, so
# these words build the dashboard's HTML on the public surface — the escape
# hatch an app is entitled to. Every gap this makes visible is logged in
# INVENTORY.md, because the exam's whole point is finding them.
module DashboardWords
  # --- the layout's chrome ----------------------------------------------

  def site_nav
    nav = subject.fetch(:nav)
    emit_node(element(:div, { class: 'sp-nav' },
                  [element(:div, { class: 'sp-nav-inner' },
                       [element(:a, { class: 'sp-nav-brand', href: '/' }, ['~/dev']),
                        nav_link('Studio', '/', nav[:studio]),
                        nav_link('Library', '/library', nav[:library]),
                        nav_link('Reconcile', '/reconcile', nav[:reconcile]),
                        nav_link('Dispatch', '/dispatch', nav[:dispatch]),
                        element(:span, { class: 'sp-nav-sep' }, []),
                        nav_link('Ports', '/ports', nav[:ports]),
                        search_form])]))
  end

  def error_card
    err = subject.fetch(:error_entry)
    return unless err && !err[:log].to_s.strip.empty?

    emit_node(element(:div, { class: 'sp-page sp-page--wide',
                          style: 'padding-top: 1rem; padding-bottom: 0;' },
                  [element(:details, { class: 'sp-card', open: 'open',
                                   style: 'border-color: var(--sp-danger, #d9534f); background: #fff8f8; padding: 1.25rem;' },
                       [element(:summary, { class: 'sp-text-strong',
                                        style: 'color: var(--sp-danger, #d9534f); cursor: pointer; font-size: 1rem;' },
                            ["Launch Error Log — #{err[:project]} (click to collapse/expand)"]),
                        element(:p, { class: 'sp-text-sm sp-text-muted', style: 'margin-top: 0.5rem;' },
                            ["Command failed on launch. Showing log from data/log/#{err[:project].to_s.gsub('/', '__')}.log:"]),
                        element(:pre, { style: 'white-space: pre-wrap; font-family: monospace; font-size: 0.85rem; margin-top: 0.5rem; color: #222; background: #fff; padding: 1rem; border: 1px solid #ffcccc; border-radius: 4px; line-height: 1.4; max-height: 350px; overflow-y: auto;' },
                            [err[:log]]),
                        element(:div, { class: 'sp-cluster sp-cluster--tight', style: 'margin-top: 0.75rem;' },
                            [element(:a, { class: 'sp-btn sp-btn--sm sp-btn--ghost',
                                       href: "/projects/#{err[:project]}/log" }, ['View Full Log File']),
                             element(:a, { class: 'sp-btn sp-btn--sm sp-btn--ghost',
                                       href: "/projects/#{err[:project]}" }, ['Open Project Card'])])])]))
  end

  # The view's own wrapper — the dashboard's page root, laid around the
  # page's contents by the layout.
  def shell(&block)
    emit_node(element(:div, { class: 'sp-page sp-page--wide' }, capture(&block)))
  end

  # --- the triage page --------------------------------------------------

  def tagline(text)
    emit_node(element(:p, { class: 'sp-text-muted' }, [text]))
  end

  def notice_flash
    notice = subject.fetch(:notice)
    return unless notice

    emit_node(element(:div, { class: 'sp-flash sp-flash--notice', role: 'alert' }, [notice]))
  end

  def unreviewed_card
    n = subject.fetch(:unreviewed).to_i
    return unless n.positive?

    emit_node(element(:div, { class: 'sp-card', style: 'margin-bottom: 1rem;' },
                  [element(:div, { class: 'sp-card__body sp-cluster',
                               style: 'justify-content: space-between; align-items: baseline;' },
                       [element(:span, {},
                            [element(:span, { class: 'sp-text-strong' },
                                 ["#{n} instruction file#{'s' if n > 1} awaiting judgment"]),
                             element(:span, { class: 'sp-text-muted' },
                                 [' — hand-kept rules nobody has ruled canonical or legacy.'])]),
                        element(:a, { class: 'sp-btn sp-btn--sm sp-btn--ghost', href: '/dispatch' },
                            ['Review on Dispatch'])])]))
  end

  # The queue — first item only, like the original's word. The empty state
  # is the word's own business: it is not an empty collection, it is the
  # absence of a first item.
  def triage
    queue = subject.fetch(:queue)
    first = queue.first
    unless first
      return emit_node(element(:p, { class: 'sp-text-muted' },
                           ['All caught up. Nothing needs attention.']))
    end

    emit_node(element(:div, { class: 'sp-stack' },
                  [element(:p, { class: 'sp-text-muted' },
                       ["#{queue.size} item(s) need attention — this is the first:"]),
                   queue_card(first)]))
  end

  # --- the confirm page --------------------------------------------------

  def archive_form
    emit_node(element(:form, { method: 'post', action: '/actions/archive', class: 'sp-stack' },
        [hidden('path', subject.fetch(:archive_path)),
         hidden('confirmed', '1'),
         *((ref = subject.fetch(:archive_reference)) ? [hidden('reference', ref)] : []),
         *((to = subject.fetch(:archive_return_to)) ? [hidden('return_to', to)] : []),
         element(:div, {},
             [element(:label, { class: 'sp-text-muted', for: 'reason' }, ['Why archive this copy?']),
              element(:textarea, { class: 'sp-input', id: 'reason', name: 'reason', rows: '2', required: 'required' },
                  [subject.fetch(:archive_reason).to_s]),
              element(:p, { class: 'sp-text-muted' },
                  ['Required — the reason is recorded in the manifest and shown on the Archived page.'])]),
         element(:div, { class: 'sp-cluster sp-cluster--tight' },
             [element(:button, { type: 'submit', class: 'sp-btn sp-btn--primary' }, ['Confirm archive']),
              element(:a, { class: 'sp-btn sp-btn--neutral', href: (subject.fetch(:archive_return_to) || '/') },
                  ['Cancel'])])]))
  end

  private

  def nav_link(label, href, here)
    element(:a, { class: "sp-nav-link#{here ? ' sp-nav-link--here' : ''}", href: href }, [label])
  end

  def search_form
    element(:form, { class: 'sp-cluster sp-cluster--tight sp-nav-search', action: '/search', method: 'get' },
        [element(:input, { class: 'sp-input sp-input--auto', type: 'text', name: 'q',
                       placeholder: 'search…', value: subject.fetch(:search_q).to_s }, [])])
  end

  def queue_card(p)
    element(:article, { class: 'sp-card' },
        [element(:header, { class: 'sp-card__header' }, [element(:h3, { class: 'sp-card__title' }, [p[:path]])]),
         element(:div, { class: 'sp-card__body' },
             [summary_line(p), next_line(p), actions_row(p)].compact)])
  end

  def summary_line(p)
    element(:div, { class: 'sp-cluster' },
        [element(:span, { class: "sp-badge sp-badge--#{status_variant(p[:status])}" }, [p[:status].to_s]),
         element(:span, { class: 'sp-text-muted' }, [stale_text(p)]),
         element(:span, { class: 'sp-text-muted' }, [p[:purpose].to_s])])
  end

  def stale_text(p)
    p[:stale_days] ? "stale #{p[:stale_days]}d" : 'never committed'
  end

  # The dashboard's own map; a port of behaviour, not a vocabulary concern.
  def status_variant(status)
    { 'active' => :ok, 'repaired' => :ok, 'abandoned' => :danger,
      'dormant' => :pending }.fetch(status, :neutral)
  end

  def next_line(p)
    return if p[:next_step] == '-'

    element(:p, { class: 'sp-text-strong' }, ["Next: #{p[:next_step]}"])
  end

  def actions_row(p)
    element(:div, { class: 'sp-cluster' },
        [commit_button(p), dormant_button(p), archive_button(p), skip_button(p)].compact)
  end

  def commit_button(p)
    return unless p[:dirty] || p[:zero_commits]

    post_form('/actions/commit', p) { submit('Commit', 'primary') }
  end

  def dormant_button(p)
    post_form('/actions/status', p, { 'status' => 'dormant' }) { submit('Set dormant', 'neutral') }
  end

  def archive_button(p)
    post_form('/actions/archive', p) { submit('Archive', 'neutral') }
  end

  def skip_button(p)
    post_form('/actions/skip', p) { submit('Skip 30d', 'neutral') }
  end

  def post_form(action, p, extra = {}, &block)
    element(:form, { method: 'post', action: action },
        [hidden('path', p[:path]), hidden('return_to', '/triage'),
         *extra.map { |k, v| hidden(k, v) }, block.call])
  end

  def hidden(name, value)
    element(:input, { type: 'hidden', name: name, value: value.to_s }, [])
  end

  def submit(label, variance)
    element(:button, { type: 'submit', class: "sp-btn sp-btn--#{variance}" }, [label])
  end
end
