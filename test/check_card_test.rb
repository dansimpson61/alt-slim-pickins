# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require 'date'
require 'fileutils'

# The resume card's gate.
#
# It has held the card's YAML since DAYTRIP-0.3.0b, for a measured reason: a
# colon-space in the status scalar broke the frontmatter four times in two days,
# and each time the checker was a human remembering. DAYTRIP-0.4.0m gave it a
# second job — a budget — because the card it was guarding had grown to 32,179
# characters while this script printed the size on every green run and had no
# opinion about it.
#
# The gate runs in its own process, so these tests drive it as the gate command
# does rather than reaching inside it.
class CheckCardTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SCRIPT = File.join(ROOT, 'bin', 'check_card.rb')

  def run_against(card)
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'PROJECT.md'), "---\n#{card.to_yaml.sub(/\A---\n/, '')}---\n\nbody\n")
      FileUtils.mkdir_p(File.join(dir, 'bin'))
      FileUtils.cp(SCRIPT, File.join(dir, 'bin', 'check_card.rb'))
      output = IO.popen(['ruby', File.join(dir, 'bin', 'check_card.rb')], err: %i[child out], &:read)
      [output, $?.success?]
    end
  end

  def sound_card(**overrides)
    { 'schema_version' => 1, 'id' => 'fixture', 'purpose' => 'a fixture',
      'status' => 'where it stands', 'kind' => 'project',
      'last_touched' => '2026-10-03', 'next_step' => 'do the next thing' }
      .merge(overrides.transform_keys(&:to_s))
  end

  def test_the_real_card_passes
    output = IO.popen(['ruby', SCRIPT], err: %i[child out], &:read)

    assert $?.success?, output
    assert_match(/0 problems/, output)
  end

  def test_the_real_card_reports_every_budget_and_its_headroom
    output = IO.popen(['ruby', SCRIPT], err: %i[child out], &:read)

    %w[status next_step notes].each do |field|
      assert_match(/#{field} \d+\/\d+/, output, "#{field}'s budget is stated, so overflow is visible before it fails")
    end
  end

  # The job this gate was built for, and the one it must not lose.
  def test_unparseable_frontmatter_is_named_rather_than_silently_blank
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'PROJECT.md'), "---\nstatus: a colon: space breaks this\n---\n")
      FileUtils.mkdir_p(File.join(dir, 'bin'))
      FileUtils.cp(SCRIPT, File.join(dir, 'bin', 'check_card.rb'))
      output = IO.popen(['ruby', File.join(dir, 'bin', 'check_card.rb')], err: %i[child out], &:read)

      refute $?.success?
      assert_match(/UNPARSEABLE/, output)
      assert_match(/colon followed by a space/, output, 'the usual cause is named, not just the error')
    end
  end

  def test_a_missing_field_the_dashboard_needs_is_refused
    output, ok = run_against(sound_card.tap { |c| c.delete('next_step') })

    refute ok
    assert_match(/MISSING FIELD\s+`next_step`/, output)
  end

  # The budget, which is the whole of this round's addition.
  def test_a_field_over_its_budget_is_refused
    output, ok = run_against(sound_card(status: 'x' * 1_501))

    refute ok
    assert_match(/OVER BUDGET\s+`status` is 1501 chars against a budget of 1500/, output)
  end

  def test_a_field_inside_its_budget_is_accepted
    _output, ok = run_against(sound_card(status: 'x' * 1_500))

    assert ok, 'the budget is a ceiling, not a target'
  end

  # A budget that invites deleting the only copy of something is worse than none,
  # so the refusal says what to do instead. `history/CHRONICLE.md` exists because
  # 29,061 characters of this card turned out to live nowhere else.
  def test_the_refusal_says_to_move_the_overflow_not_to_delete_it
    output, = run_against(sound_card(notes: 'x' * 2_000))

    assert_match(/move the overflow somewhere it can be read; do not delete it/, output)
  end

  def test_every_budgeted_field_is_one_the_card_actually_has
    card = YAML.safe_load(File.read(File.join(ROOT, 'PROJECT.md'))[/\A---\n(.*?)\n---/m, 1],
                          permitted_classes: [Date])
    budgets = File.read(SCRIPT)[/BUDGETS = \{(.*?)\}\.freeze/m, 1].scan(/'([a-z_]+)'/).flatten

    refute_empty budgets
    budgets.each { |field| assert card.key?(field), "`#{field}` is budgeted but the card has no such field" }
  end
end
