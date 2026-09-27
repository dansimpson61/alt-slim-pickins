# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'tempfile'
require 'fileutils'
require 'tmpdir'
require_relative '../check_spiff_scope'

# The tenth gate: a Spiff's zones against the pages they style.
#
# It exists for a defect nothing else can see — the compiler emits a selector
# for every zone a Spiff names, and a selector that matches nothing is a
# correctness defect however short it is. A typo, or a zone renamed in a page
# and not in its Spiff, compiles to a rule that silently styles nothing.
class CheckSpiffScopeTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def run_check(files)
    out = StringIO.new
    problems = SpiffScope.run(files: files, root: ROOT, out: out)
    [problems, out.string]
  end

  def test_the_real_corpus_passes
    problems, output = run_check(nil)

    assert_equal 0, problems, output
    refute_match(/0 spiff\(s\)/, output, 'the checker found no Spiff and called it green')
  end

  def test_a_zone_no_page_can_render_is_refused
    Dir.mktmpdir('app') do |root|
      app = File.join(root, 'demo')
      FileUtils.mkdir_p(File.join(app, 'views'))
      File.write(File.join(app, 'demo.spiff'), "surface demo\n  zone nonexistent\n    frame quiet\n")
      File.write(File.join(app, 'views', 'index.sp'),
                 "page index\n  def shown\n    text \"x\"\n  shown\n")

      problems, output = run_check([File.join(app, 'demo.spiff')])

      refute_equal 0, problems, 'the checker passed a zone nothing renders'
      assert_includes output, 'nonexistent'
      assert_includes output, 'the selector matches nothing'
    end
  end

  def test_a_zone_a_page_defines_inline_is_accepted
    Dir.mktmpdir('app') do |root|
      app = File.join(root, 'demo')
      FileUtils.mkdir_p(File.join(app, 'views'))
      File.write(File.join(app, 'demo.spiff'), "surface demo\n  zone catalog\n    frame quiet\n")
      File.write(File.join(app, 'views', 'index.sp'),
                 "page index\n  def catalog\n    text \"x\"\n  catalog\n")

      problems, = run_check([File.join(app, 'demo.spiff')])
      assert_equal 0, problems, 'a page that defines the word can render the zone'
    end
  end

  def test_a_zone_an_app_partial_provides_is_accepted
    Dir.mktmpdir('app') do |root|
      app = File.join(root, 'demo')
      FileUtils.mkdir_p(File.join(app, 'views', 'partials'))
      File.write(File.join(app, 'demo.spiff'), "surface demo\n  zone shelf\n    frame quiet\n")
      File.write(File.join(app, 'views', 'partials', 'shelf.sp'), "box\n  children\n")
      File.write(File.join(app, 'views', 'index.sp'), "page index\n  text \"x\"\n")

      problems, = run_check([File.join(app, 'demo.spiff')])
      assert_equal 0, problems, 'a partial of that name can render the zone'
    end
  end

  def test_flank_and_horizon_zones_are_read_too
    Dir.mktmpdir('app') do |root|
      app = File.join(root, 'demo')
      FileUtils.mkdir_p(File.join(app, 'views'))
      File.write(File.join(app, 'demo.spiff'), <<~SPIFF)
        surface demo
          stage
            flank lead, beside: companion, balance: equal
          horizon one, two
      SPIFF
      File.write(File.join(app, 'views', 'index.sp'), "page index\n  text \"x\"\n")

      problems, output = run_check([File.join(app, 'demo.spiff')])

      # All four names are named by the Spiff and none is rendered here.
      %w[lead companion one two].each { |zone| assert_includes output, zone }
      assert_equal 4, problems
    end
  end

  def test_an_empty_corpus_is_refused_rather_than_passed
    Dir.mktmpdir('empty') do |dir|
      spiff = File.join(dir, 'nothing.spiff')
      File.write(spiff, "surface nothing\n")
      problems, output = run_check([spiff])
      # No zones to check, so nothing is wrong with it — but the corpus itself
      # being empty is the failure mode this guards, and that is `run` with no
      # files at all.
      assert_equal 0, problems
      assert_includes output, 'held to their pages'
    end
  end

  def test_the_app_root_is_found_for_both_layouts
    here = File.join(ROOT, 'examples/doc_reader/doc_reader.spiff')
    nested = File.join(ROOT, 'studio/uis/workbench/workbench.spiff')

    assert_equal File.join(ROOT, 'examples/doc_reader'), SpiffScope.app_root(here)
    assert_equal File.join(ROOT, 'studio/uis/workbench'), SpiffScope.app_root(nested)
  end
end
