# frozen_string_literal: true

require 'minitest/autorun'
require 'date'
require_relative '../lib/slim_pickins'

# Phase 4: the whole vocabulary. One test per group of words, plus the two
# collisions with the host language that only surfaced once real pages ran.
class Phase4Test < Minitest::Test
  def render(source, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals)
  end

  def test_every_documented_word_is_implemented
    documented = File.read(File.expand_path('../VOCABULARY.md', __dir__))
                     .scan(/^### `([a-z_]+)`/).flatten.map(&:to_sym)
    assert_empty documented - SlimPickins::Builder::WORDS
  end

  # --- structure --------------------------------------------------------

  def test_grid_list_item_card_aside_and_figure
    html = render(<<~PAGE, thing: { id: 7 })
      page thing
        grid cards, columns: 3
          card compact
            title "In a card"
        list plain
          item "One"
        aside
          figure "A caption"
            image "/a.png", alt: "A"
    PAGE
    assert_includes html, '<div class="grid grid--cards" style="--columns: 3">'
    assert_includes html, '<article class="card card--compact" id="thing-7">'
    assert_includes html, '<ul class="list list--plain"><li class="item">One</li></ul>'
    assert_includes html, '<figcaption>A caption</figcaption>'
    assert_includes html, '<img src="/a.png" alt="A" loading="lazy">'
  end

  # --- content ----------------------------------------------------------

  def test_note_badge_fact_snippet_and_icon
    html = render(<<~PAGE, thing: { origin: 'dashboard', status: 'ok' })
      page thing
        note warning, "Careful."
        badge .status
        fact origin
        snippet ruby, "puts 1"
        icon warning
    PAGE
    assert_includes html, '<p class="note note--warning">Careful.</p>'
    assert_includes html, '<span class="badge badge--ok">ok</span>'
    assert_includes html, '<dt>Origin</dt><dd>dashboard</dd>'
    assert_includes html, '<pre class="snippet snippet--ruby"><code>puts 1</code></pre>'
    assert_includes html, 'class="icon icon--warning"'
  end

  # `icon warning` and `icon .severity` name the same thing two ways.
  def test_an_icon_may_be_named_or_arrive_as_data
    html = render("page thing\n  icon .severity\n", thing: { severity: 'blocker' })
    assert_includes html, 'class="icon icon--blocker"'
  end

  def test_time_renders_machine_readable_alongside_human
    html = render("page thing\n  time .on\n", thing: { on: Date.new(2026, 8, 30) })
    assert_includes html, '<time datetime="2026-08-30">30 August 2026</time>'
  end

  def test_metric_derives_label_and_value_from_one_word
    html = render("page thing\n  metric total_value, \"Total value\"\n",
                  thing: { total_value: 1500 })
    assert_includes html, '<h3 class="metric-label">Total value</h3>'
    assert_includes html, '<div class="metric-value">1,500</div>'
  end

  # --- prose is safe by construction ------------------------------------

  def test_prose_renders_markdown
    html = render(%(page thing\n  prose .body\n), thing: { body: 'A **bold** claim.' })
    assert_includes html, '<div class="prose"><p>A <strong>bold</strong> claim.</p></div>'
  end

  # There is no "trust me" spelling, so no input can produce a tag that
  # markdown does not define. This is why the language has no escaping sigil.
  def test_prose_cannot_be_made_to_emit_arbitrary_html
    html = render(%(page thing\n  prose .body\n),
                  thing: { body: '<script>alert(1)</script>' })
    refute_includes html, '<script>alert(1)</script>'
    assert_includes html, '&lt;script&gt;'
  end

  def test_prose_plain_takes_no_markup_at_all
    html = render("page thing\n  prose plain, .body\n", thing: { body: '**not bold**' })
    assert_includes html, '<p>**not bold**</p>'
  end

  # --- situation --------------------------------------------------------

  def test_choose_renders_the_first_true_branch
    html = render(<<~PAGE, thing: { drifted?: true })
      page thing
        choose
          when .drifted?
            note warning, "Drifted."
          otherwise
            note quiet, "On target."
    PAGE
    assert_includes html, 'Drifted.'
    refute_includes html, 'On target.'
  end

  def test_choose_falls_through_to_otherwise
    html = render(<<~PAGE, thing: { drifted?: false })
      page thing
        choose
          when .drifted?
            note warning, "Drifted."
          otherwise
            note quiet, "On target."
    PAGE
    assert_includes html, 'On target.'
    refute_includes html, 'Drifted.'
  end

  def test_when_outside_a_choose_says_where_it_belongs
    error = assert_raises(SlimPickins::Error) do
      render("page thing\n  when .x\n    note \"y\"\n", thing: { x: true })
    end
    assert_equal 'when belongs inside a choose', error.message
  end

  # --- collisions with the host language ---------------------------------

  # `when` is a Ruby keyword: it can be defined as a method but never called
  # as one. The transform routes reserved words past Ruby's parser so the
  # language keeps its own word.
  def test_a_reserved_word_still_compiles
    assert_includes SlimPickins.compile("choose\n  when .x\n    note \"y\"\n"),
                    'send(:when, subject.x)'
  end

  # Arguments are evaluated before the word runs, so `.foo` in a word's own
  # arguments asks the *enclosing* subject, not the one it is about to
  # establish. The binding spelling is the one that works.
  def test_a_words_own_arguments_see_the_enclosing_subject
    html = render(%(page pattern, pattern.title\n  title "x"\n),
                  pattern: { title: 'The Pattern' })
    assert_includes html, '<title>The Pattern</title>'
  end

  # --- chart, the entry still marked a guess -----------------------------

  def test_chart_renders_something_honest_for_each_kind
    %i[line bar pie area].each do |kind|
      svg = SlimPickins::Charting.render(kind, [1, 2, 3], label: 'k')
      assert_includes svg, %(class="chart chart--#{kind}")
      assert_includes svg, '<title>k</title>'
    end
  end

  def test_a_chart_of_nothing_renders_nothing
    assert_equal '', SlimPickins::Charting.render(:line, [])
  end
end
