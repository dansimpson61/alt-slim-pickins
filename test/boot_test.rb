# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/slim_pickins'
require_relative '../examples/roth/app'

# The roth test — the payload's second step. Renaming or removing an
# attribute makes the roth page fail at boot, naming the line and the
# attribute. The eleven-month silence — an attribute renamed in the model
# while the page kept the old name, rendering blank — is a boot error, by
# construction.
class BootTest < Minitest::Test
  ROTH_VIEWS = File.expand_path('../examples/roth/views', __dir__)

  # The model, minus `ss_primary_amount` — what roth's rename did to the
  # engine, played on the real page.
  def lame_scenario
    Class.new do
      def initialize(scenario) = @scenario = scenario

      def method_missing(name, ...) = @scenario.public_send(name, ...)

      def respond_to_missing?(name, _include_private = false)
        name != :ss_primary_amount && @scenario.respond_to?(name)
      end
    end.new(Roth::Scenario.defaults)
  end

  def test_removing_an_attribute_fails_at_boot_naming_the_line_and_the_attribute
    error = assert_raises(SlimPickins::UnknownAttribute) do
      SlimPickins.prove!(ROTH_VIEWS) do |_name|
        { scenario: lame_scenario, projection: Roth::Projection.of(Roth::Scenario.defaults) }
      end
    end
    assert_match(/\Athis scenario has no ss_primary_amount\n  .*controls\.sp, line 14\n    field ss_primary_amount\z/,
                 error.message)
  end

  def test_boot_proves_every_top_level_view_and_names_each
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'layout.sp'), "nav\n  link home\ncontents\n")
      File.write(File.join(dir, 'one.sp'), "page one\n  title .name\n")
      File.write(File.join(dir, 'two.sp'), "page two\n  text .blurb\n")
      out, = capture_io do
        SlimPickins.prove!(dir) { |_name| { one: { name: 'A' }, two: { blurb: 'B' } } }
      end
      assert_includes out, 'proved one.sp'
      assert_includes out, 'proved two.sp'
      refute_includes out, 'layout'
    end
  end

  def test_a_view_the_block_answers_nothing_for_is_refused_loudly
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), "page one\n  title .name\n")
      error = assert_raises(SlimPickins::Error) do
        capture_io { SlimPickins.prove!(dir) { |_name| nil } }
      end
      assert_match(/\Ano locals were given to prove `one\.sp`/, error.message)
    end
  end
end
