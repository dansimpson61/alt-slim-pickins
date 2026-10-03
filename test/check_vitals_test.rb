# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'tmpdir'
require_relative '../check_vitals'

# The eleventh gate: a number this project states about itself against the
# census that measures it.
#
# The gate's whole difficulty is telling a claim from a record, and every rule
# it uses to do that is a judgement someone could reasonably make differently.
# So each one is asked here by name: a rule nothing tests is a rule the next
# round will quietly widen.
class CheckVitalsTest < Minitest::Test
  WORDS = SlimPickins::Census.snapshot[:canonical_words]

  def claims(text, file: 'fixture.md')
    Vitals.claims_in(text, file: file, start: 1)
  end

  def stale(text, **)
    claims(text, **).reject(&:true?)
  end

  # --- the corpus itself ----------------------------------------------------
  def test_the_real_corpus_agrees_with_the_census
    out = StringIO.new
    assert_equal 0, Vitals.run(out: out), out.string
  end

  def test_the_corpus_is_actually_read
    out = StringIO.new
    Vitals.run(out: out)
    assert_match(/\d+ prose claims read across \d+ documents/, out.string)
    refute_match(/ 0 prose claims /, out.string, 'a gate that reads nothing cannot report anything')
  end

  # --- what a claim is ------------------------------------------------------
  def test_a_number_beside_a_vitals_name_is_a_claim
    found = stale("The language has #{WORDS + 1} canonical words today.")
    assert_equal 1, found.size
    assert_equal WORDS + 1, found.first.stated
    assert_equal :canonical_words, found.first.vital.key
  end

  def test_a_number_the_prose_spells_out_is_a_claim
    assert_equal 1, stale('sixty-four words, and no apology').size,
                 'a gate blind to spelled numbers teaches the project to spell them out'
  end

  def test_the_more_specific_vital_claims_the_text_first
    found = claims('26 app words')
    assert_equal [:app_words], found.map { |claim| claim.vital.key }
  end

  def test_the_reverse_form_a_gates_vitals_row_uses_is_a_claim
    assert_equal 1, stale("words: #{WORDS + 2}").size
  end

  # --- and what is not ------------------------------------------------------
  def test_a_number_inside_a_quoted_span_is_exhibited_not_asserted
    assert_empty stale('It used to read `WORDS = 64`, which is the defect this deleted.')
    assert_empty stale('A good answer looks like "887 sentences, 103 rules, 13 pages".')
  end

  def test_a_quoted_span_that_wraps_a_line_is_still_quoted
    assert_empty stale("re-measured on the clean tree — `659 sentences, 93 rules,\n" \
                       '64 words all 64 used, 10 pages` — and both files carry them')
  end

  def test_a_number_inside_a_date_is_not_a_count
    assert_empty stale('until 2026-09-17 no Word instance answered it')
  end

  def test_a_list_marker_is_not_a_count
    assert_empty stale("1. **The page** must answer.\n2. **The app** must promise.")
    assert_empty stale("#   4. **No word** may invent syntax.\n")
  end

  def test_a_number_more_than_one_word_from_the_noun_is_not_its_count
    assert_empty stale('Phase 0 built this word and measured it.')
    assert_empty stale('the theme owns 61 roles and no page can say one')
  end

  def test_a_spelled_number_below_twenty_is_a_determiner
    assert_empty stale('one resolution rule, and two words fixed it'),
                 'English uses these as determiners far more often than as counts'
  end

  # --- the elided form that hid inside a gate for a month -------------------
  def test_n_of_m_names_the_total_and_the_block_names_the_vital
    found = stale('every word declares a part of speech — the language is a noun language (59 of 64)')
    assert_equal 1, found.size
    assert_equal 64, found.first.stated
  end

  def test_n_of_m_holds_to_the_same_twenty_floor
    assert_empty stale("Measured on the roth form:\n| labels written in the page | 11 of 14 |"),
                 'a coverage fraction over a vital is a fraction over a vital-sized set'
  end

  # --- Ruby is prose in two places -----------------------------------------
  def test_a_string_an_app_shows_a_reader_is_prose
    found = Vitals.claims_in('exercising different regions of the frozen 64 words.',
                             file: 'planner.rb', start: 1)
    assert_equal 1, found.reject(&:true?).size
  end

  def test_an_interpolated_string_is_not_a_hand_kept_literal
    source = %(options = { c: "#{'#{Census.words[:total].size}'} words" }\n)
    assert_empty Vitals.strings_of(source).flat_map { |line, body|
      Vitals.claims_in(body, file: 'exam.rb', start: line).reject(&:true?)
    }, 'a string that computes part of itself cannot go stale'
  end

  # --- rule two: a vital's key, assigned a literal --------------------------

  # Rule two has to tell an assignment from a fixture, and the whole difficulty
  # is that Ruby writes a string five ways. Every one of these cases was decided
  # by running it, and three of them were wrong at some point in this round's own
  # construction — the double-quoted date, the quoted literal, and the fixture
  # written with `%(...)` all slipped a version of the rule that looked finished.
  # So the rule is specified as a table rather than described in prose.
  LITERAL_CASES = {
    'a bare literal is refused' => ["locals = { word_count: 64 }\n", %w[HARDCODED]],
    'a quoted literal is refused' => [%(locals = { word_count: "64" }\n), %w[HARDCODED]],
    'a single-quoted stamp is refused' => ["locals = { measured: '2026-09-17' }\n", %w[STAMPED]],
    'a double-quoted stamp is refused' => [%(locals = { measured: "2026-09-17" }\n), %w[STAMPED]],
    'reading the census is accepted' => ["locals = { word_count: StudioVitals::WORDS }\n", []],
    'a comment narrating the literal it deleted is accepted' =>
      ["# This line held `word_count: 64` and was stale by the time it mattered.\n", []],
    'a fixture inside a string is accepted' => [%(write("locals = { word_count: 64 }")\n), []],
    'a fixture inside a percent literal is accepted' => [%(write(%(locals = { word_count: 64 }))\n), []]
  }.freeze

  def test_an_assignment_is_told_from_a_fixture
    LITERAL_CASES.each do |label, (source, expected)|
      in_a_file(source) { |path| assert_equal expected, Vitals.literals_in([path]).map(&:kind), label }
    end
  end

  def test_the_report_names_the_census_key_that_answers_the_question
    in_a_file("locals = { word_count: 64, pages_count: 22 }\n") do |path|
      messages = Vitals.literals_in([path]).map(&:message)
      assert(messages.any? { |m| m.include?('Census.snapshot[:canonical_words]') })
      assert(messages.any? { |m| m.include?('Census.snapshot[:verified_pages]') })
    end
  end

  # --- the line between a claim and a record -------------------------------
  def test_the_dated_record_is_exempt_and_every_exemption_carries_a_reason
    %w[LORE.md ROADMAP-0.3.md DAYTRIP-0.4.0h.md KERNEL.md].each do |name|
      assert Vitals.exempt?("/anywhere/#{name}"), "#{name} is a record, not a claim about now"
    end
    refute Vitals.exempt?('/anywhere/README.md'), 'the front door states numbers about now'
    assert Vitals::EXEMPT.values.all? { |reason| reason.to_s.length > 20 },
           'a reason can be disagreed with; a bare skip list cannot'
  end

  def in_a_file(source)
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'fixture.rb')
      File.write(path, source)
      yield path
    end
  end
end
