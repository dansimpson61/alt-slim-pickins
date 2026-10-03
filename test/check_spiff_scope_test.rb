# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'fileutils'
require 'tmpdir'
require_relative '../check_spiff_scope'

# The Spiff gate, retargeted in DAYTRIP-0.4.0j: a compiled selector against the
# HTML the pages it governs really render.
#
# It used to compare a Spiff's zone names to the `.sp` sources in its directory,
# which passed two whole classes of defect — a selector the compiler emits that
# is not a zone at all, and a word defined on disk that nothing ever reaches.
# Both are asked here by name, because the retarget's entire justification is
# that those two cases now fail.
class CheckSpiffScopeTest < Minitest::Test
  WORKBENCH = File.expand_path('../studio/uis/workbench/workbench.spiff', __dir__)

  def run_check(spiffs: nil, pages: nil, root: SpiffScope::ROOT)
    out = StringIO.new
    problems = SpiffScope.run(spiffs: spiffs, pages: pages || PAGES, root: root, out: out)
    [problems, out.string]
  end

  # Run in a process of its own, as the gate itself is, and not through
  # `SpiffScope.run` in here.
  #
  # The word registry is global and last-compile-wins. `studio_try_test.rb` says
  # so in its own comment and depends on it: it merges the classic UI's library
  # into the registry, after which the workbench's `editor` partial is no longer
  # the one that renders. So in a shared suite this assertion's result depends on
  # test order — it passed alone and failed after `studio_try_test`, which is how
  # the fragility was found rather than assumed.
  #
  # That is a pre-existing property of the runtime, not of this gate, and it is
  # why `bin/verify_pages.rb` has always had a process to itself. A gate that
  # renders needs the same. The fixture tests below stay in-process because an
  # in-buffer `def` is page-local and owes the registry nothing.
  def test_the_real_corpus_passes
    output = IO.popen(['ruby', File.join(SpiffScope::ROOT, 'check_spiff_scope.rb')],
                      err: %i[child out], &:read)
    assert_match(/0 problems/, output, output)
    assert_match(/2 spiff\(s\), \d+ compiled classes held/, output)
  end

  # The measurement that justified retargeting rather than deleting: the old
  # check read three zone names out of the eleven classes the compiler emits.
  def test_every_class_the_compiler_emits_is_checked_not_only_the_zones
    targeted = SpiffScope.targeted_classes(WORKBENCH)
    %w[editor library output].each { |zone| assert_includes targeted, zone }
    %w[panes shell tabs].each do |beyond|
      assert_includes targeted, beyond,
                      "`#{beyond}` is a class the compiler targets and the zone-name walk never saw"
    end
    assert_operator targeted.size, :>, 3
  end

  def test_an_at_rule_is_not_a_selector
    refute_includes SpiffScope.targeted_classes(WORKBENCH), 'media'
    refute_includes SpiffScope.targeted_classes(WORKBENCH), 'container'
  end

  # --- the two defects the name-based version passed ------------------------
  def test_a_selector_matching_nothing_is_refused
    in_a_corpus(zone: 'librery') do |root, spiffs, pages|
      problems, output = run_check(spiffs: spiffs, pages: pages, root: root)
      assert_equal 1, problems, output
      assert_match(/MATCHES NOTHING/, output)
      assert_match(/`\.librery`/, output)
    end
  end

  # The upgrade, stated as a test: `ghost` is a real word on disk, so the
  # zone-name check accepted it. Nothing renders it, so this one does not.
  def test_a_class_defined_but_never_rendered_is_refused
    in_a_corpus(zone: 'ghost', define: 'ghost') do |root, spiffs, pages|
      problems, output = run_check(spiffs: spiffs, pages: pages, root: root)
      assert_equal 1, problems, output
      assert_match(/compiles a selector for `\.ghost`/, output)
    end
  end

  def test_a_zone_the_page_renders_is_accepted
    in_a_corpus(zone: 'panel', render: 'panel') do |root, spiffs, pages|
      problems, output = run_check(spiffs: spiffs, pages: pages, root: root)
      assert_equal 0, problems, output
    end
  end

  # --- a Spiff with nothing to answer to -----------------------------------
  def test_a_spiff_whose_pages_are_not_rendered_is_refused_rather_than_passed
    in_a_corpus(zone: 'panel', render: 'panel') do |root, spiffs, _pages|
      problems, output = run_check(spiffs: spiffs, pages: [], root: root)
      assert_equal 1, problems, output
      assert_match(/UNRENDERED/, output)
      assert_match(/governs no page the corpus renders/, output)
    end
  end

  def test_an_empty_corpus_is_refused_rather_than_passed
    problems, output = run_check(spiffs: [], pages: [])
    assert_equal 1, problems
    assert_match(/NO SPIFFS/, output)
  end

  def test_scope_is_the_spiffs_own_directory
    scope = SpiffScope.scope_of(WORKBENCH, pages: PAGES)
    refute_empty scope
    scope.each { |label, _library, _locals| assert_includes label, 'studio/uis/workbench/' }
    assert_equal scope.size, PAGES.count { |l, _, _| l.start_with?('studio/uis/workbench/') }
  end

  # A fixture app: one page, its own Spiff, and whichever of the two halves of
  # the question the test wants to put out of step.
  def in_a_corpus(zone:, define: nil, render: nil)
    Dir.mktmpdir do |root|
      app = File.join(root, 'examples', 'fixture')
      FileUtils.mkdir_p(File.join(app, 'views', 'partials'))
      if define
        File.write(File.join(app, 'views', 'partials', "#{define}.sp"),
                   "text \"a word on disk that nothing reaches\"\n")
      end
      # An in-buffer `def` promotes its own name onto the element's class, which
      # is the mechanism a zone's selector relies on.
      body = if render
               "  #{render}\n\ndef #{render}\n  text \"inside the zone\"\n"
             else
               "  heading \"Fixture\"\n"
             end
      File.write(File.join(app, 'views', 'index.sp'), "page \"Fixture\"\n#{body}")
      File.write(File.join(app, 'fixture.spiff'),
                 "surface fixture\n  stage\n    air generous\n\n  zone #{zone}\n    frame flat\n")

      library = SlimPickins::Library.from(File.join(app, 'views'))
      pages = [['examples/fixture/views/index.sp', library, {}]]
      yield root, [File.join(app, 'fixture.spiff')], pages
    end
  end
end
