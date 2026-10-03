# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'tmpdir'
require_relative '../check_ruby'

# The twelfth gate: `ruby -w -c` over every Ruby file the project owns.
#
# The gate's value rests on two measured claims about the mechanism, and both
# obvious shortcuts break it silently rather than loudly — so both are held
# here. A gate that checks one file of a hundred, or that misses the warning
# class it was built for, still prints `0 problems`.
class CheckRubyTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def check(source)
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'fixture.rb')
      File.write(path, source)
      yield RubyShape.findings_in(path)
    end
  end

  def test_the_whole_tree_is_clean
    out = StringIO.new
    assert_equal 0, RubyShape.run(out: out), out.string
  end

  def test_the_gate_reaches_the_runtime_the_gates_the_suite_and_the_examples
    files = RubyShape.all_files.map { |path| path.delete_prefix("#{ROOT}/") }
    %w[lib/slim_pickins/builder.rb studio/app.rb bin/verify_pages.rb
       check_vitals.rb test/check_ruby_test.rb examples/word_graph/lib/graph.rb].each do |expected|
      assert_includes files, expected
    end
  end

  # The warning class the gate exists for: `Generator#emit` spanned four
  # indentation regimes under a correctly-indented `def`, so a scan of `def`
  # lines could not see it and neither could any other gate.
  def test_a_mismatched_indentation_is_refused
    check("def a\n  x = 1\n  x\n ensure\n end\n") do |findings|
      assert findings.any? { |f| f.message.include?('mismatched indentations') },
             'this is the warning that found every defect in the round that motivated this gate'
      assert_equal ['WARNING'], findings.map(&:kind).uniq
    end
  end

  def test_an_assignment_nothing_reads_is_refused
    check("def a\n  unread = compute\n  2\nend\n") do |findings|
      assert findings.any? { |f| f.message.include?('assigned but unused variable - unread') }
      assert_equal '2', findings.first.line
    end
  end

  def test_a_file_that_will_not_parse_says_so_rather_than_warning
    check("def a\n  if true\n") do |findings|
      refute_empty findings
      assert_equal ['WILL NOT PARSE'], findings.map(&:kind).uniq,
                   'a warning and a broken file are different findings and read differently'
    end
  end

  def test_a_clean_file_is_accepted
    check("# frozen_string_literal: true\n\ndef a\n  1 + 1\nend\n") { |findings| assert_empty findings }
  end
end
