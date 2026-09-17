# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/promises'
require_relative '../lib/slim_pickins/conventions'

# The two instruments of DAYTRIP-0.3.0b, held by the suite rather than only by
# their own checkers. An instrument that nothing holds is an unmanaged source of
# truth — which is the thing this daytrip exists to stop.
#
# Both checkers (`bin/check_promises.rb`, `bin/check_conventions.rb`) are gate
# legs; these tests are what makes a broken instrument a red suite as well.
class InstrumentsTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    SlimPickins::Library.builtin
  end

  # --- the promise ledger -----------------------------------------------------

  # The debt is pinned deliberately. When a ruling lands — `if:` implemented, or
  # `boolean?` deleted — this list changes *on purpose* and the change is the
  # record that a promise gained a reader or stopped being made. It held three
  # until 2026-09-17, when dan ruled `PrimitiveShapes` deleted.
  KNOWN_UNREAD = %i[if boolean?].freeze

  def test_the_ledger_records_exactly_the_promises_we_know_are_unread
    assert_equal KNOWN_UNREAD.sort, SlimPickins::Promises.outstanding.map(&:name).sort,
                 'the set of promises with no reader moved — a ruling landed, or a promise ' \
                 'quietly stopped being made; either way the ledger must say so'
  end

  def test_every_unread_promise_carries_its_reason
    SlimPickins::Promises.outstanding.each do |promise|
      refute_nil promise.note, "`#{promise.name}` is recorded unread with no reason"
      refute_empty promise.note.to_s.strip, "`#{promise.name}` is recorded unread with a blank reason"
    end
  end

  def test_the_ledger_covers_every_live_declared_modifier
    live = SlimPickins::Promises.language_words.flat_map do |word|
      SlimPickins::CONTRACTS[word]&.modifiers.to_a
    end.uniq
    ledgered = SlimPickins::Promises::ALL.map(&:name)

    assert_empty live - ledgered, 'a declared modifier is not in the promise ledger'
  end

  def test_the_ledger_covers_every_universal_modifier_the_gate_permits
    ledgered = SlimPickins::Promises::ALL.select { |p| p.kind == :universal }.map(&:name)

    assert_equal SlimPickins::Contracts::UNIVERSAL_MODIFIERS.sort, ledgered.sort
  end

  def test_every_recorded_reader_still_exists
    SlimPickins::Promises::ALL.each do |promise|
      promise.read_by.each do |path|
        assert File.file?(File.join(ROOT, path)),
               "`#{promise.name}` says #{path} reads it, and #{path} is not there"
      end
    end
  end

  def test_a_promise_the_gate_permits_and_nothing_reads_is_not_hidden
    if_promise = SlimPickins::Promises::ALL.find { |p| p.name == :if }

    refute_nil if_promise, 'the ledger no longer records `if:`'
    assert_equal :none, if_promise.verdict
    assert_includes SlimPickins::Contracts::UNIVERSAL_MODIFIERS, :if
  end

  # --- the convention register ------------------------------------------------

  def test_every_convention_names_a_home_that_exists
    SlimPickins::Conventions::ALL.each do |convention|
      path = File.join(ROOT, convention.file)

      assert File.file?(path), "`#{convention.name}` names #{convention.file}, which is not there"
      assert_includes File.read(path), convention.marker,
                      "`#{convention.name}` says #{convention.file} holds #{convention.marker.inspect}"
    end
  end

  def test_every_convention_says_how_to_override_it
    SlimPickins::Conventions::ALL.each do |convention|
      refute_nil convention.override, "`#{convention.name}` does not say how it is overridden"
    end
  end

  def test_inference_is_exactly_partitioned_between_the_register_and_the_internal_list
    live = SlimPickins::Inference.singleton_methods(false).map(&:to_sym).sort
    claimed = SlimPickins::Conventions::ALL.flat_map { |c| Array(c.inference) }.map(&:to_sym)
    internal = SlimPickins::Conventions::INTERNAL.keys.map(&:to_sym)

    assert_equal live, (claimed + internal).sort,
                 'an Inference function is unregistered, or the register claims one that is gone'
    assert_equal claimed.sort, claimed.uniq.sort, 'an Inference function is claimed by two entries'
  end

  def test_every_grade_is_represented_and_the_axiomatic_one_records_its_absence
    %i[structural shape domain axiomatic].each do |grade|
      refute_empty SlimPickins::Conventions.by_grade(grade),
                   "nothing registers the `#{grade}` grade"
    end

    axiomatic = SlimPickins::Conventions.by_grade(:axiomatic)

    assert_equal 1, axiomatic.size, 'the axiomatic grade should hold exactly one entry — the absence itself'
    assert_match(/NOTHING/, axiomatic.first.decides)
  end

  def test_a_word_that_declares_an_inference_is_registered
    declaring = SlimPickins::Promises.language_words.select do |word|
      contract = SlimPickins::CONTRACTS[word]

      contract && (contract.id || contract.label)
    end.sort

    assert_equal %i[card section], declaring,
                 'the words declaring an inference changed; the register was written for card and section'
  end
end
