# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/slim_pickins'

# Which tin a page wears, and which Spiff presents it.
#
# Both are two-tier: a view may carry its own (`[view].tin`, `[view].spiff`)
# or inherit the app's (`[app].tin`, `[app].spiff`), and the view's word wins.
# The rule lives in one place — `Library` — because it is the same rule for
# both documents, and because it used to live in the studio, which meant the
# language did not know a page could have its own chrome and only the studio
# could find the document that said how a page sits.
class ResolutionTest < Minitest::Test
  # A whole small app on disk: an app tin and Spiff, a per-view tin and Spiff,
  # and two views — one that carries its own and one that inherits.
  def with_app
    Dir.mktmpdir('app') do |root|
      app = File.join(root, 'demo')
      views = File.join(app, 'views')
      FileUtils.mkdir_p(File.join(app, 'partials'))
      FileUtils.mkdir_p(views)
      File.write(File.join(app, 'demo.tin'), "nav\n  link home\ncontents\n")
      File.write(File.join(app, 'demo.spiff'), "surface demo\n  stage\n    air generous\n")
      File.write(File.join(views, 'own.tin'), "footer \"its own chrome\"\ncontents\n")
      File.write(File.join(views, 'own.spiff'), "surface own\n  stage\n    air tight\n")
      File.write(File.join(views, 'plain.sp'), "page plain\n  text \"x\"\n")
      File.write(File.join(views, 'own.sp'), "page own\n  text \"x\"\n")
      yield app, views
    end
  end

  # --- the tin -------------------------------------------------------------

  def test_a_view_with_its_own_tin_uses_it
    with_app do |_app, views|
      lib = SlimPickins::Library.from(views)
      assert_includes lib.tin_for('own'), 'its own chrome'
    end
  end

  def test_a_view_without_one_inherits_the_apps_tin
    with_app do |_app, views|
      lib = SlimPickins::Library.from(views)
      assert_includes lib.tin_for('plain'), 'link home'
    end
  end

  def test_the_app_tin_is_the_answer_when_the_view_is_unknown
    with_app do |_app, views|
      lib = SlimPickins::Library.from(views)
      assert_includes lib.tin_for(nil), 'link home'
      assert_includes lib.tin_for('nowhere'), 'link home'
    end
  end

  def test_a_view_with_no_tin_anywhere_is_left_unframed
    Dir.mktmpdir('bare') do |root|
      app = File.join(root, 'bare')
      FileUtils.mkdir_p(app)
      File.write(File.join(app, 'one.sp'), "page one\n  text \"x\"\n")

      lib = SlimPickins::Library.from(app)
      assert_nil lib.tin_for('one'), 'a standalone page carries its own chrome'
    end
  end

  # --- the Spiff -----------------------------------------------------------

  def test_a_view_with_its_own_spiff_uses_it
    with_app do |_app, views|
      spiff = SlimPickins::Library.spiff_for('own', path: File.join(views, 'own.sp'))
      assert_includes spiff, 'surface own'
    end
  end

  def test_a_view_without_one_inherits_the_apps_spiff
    with_app do |_app, views|
      spiff = SlimPickins::Library.spiff_for('plain', path: File.join(views, 'plain.sp'))
      assert_includes spiff, 'surface demo'
    end
  end

  def test_a_page_with_no_spiff_anywhere_is_not_an_error
    Dir.mktmpdir('bare') do |root|
      app = File.join(root, 'bare')
      FileUtils.mkdir_p(app)
      view = File.join(app, 'one.sp')
      File.write(view, "page one\n  text \"x\"\n")

      assert_nil SlimPickins::Library.spiff_for('one', path: view),
                 'a page with nowhere to say how it sits wears the stylesheet as it is'
    end
  end

  def test_the_apps_spiff_is_found_beside_the_app_when_views_are_nested
    with_app do |app, views|
      # `demo/demo.spiff`, one level above `demo/views/` — the shape
      # doc_reader uses, and the reason the lookup tries the outer name too.
      plain = File.join(views, 'plain.sp')
      assert_includes SlimPickins::Library.spiff_for('plain', path: plain), 'surface demo'
      assert File.file?(File.join(app, 'demo.spiff'))
    end
  end

  # --- the two rules agree -------------------------------------------------

  def test_tin_and_spiff_resolve_by_the_same_precedence
    with_app do |_app, views|
      lib = SlimPickins::Library.from(views)
      own_tin = lib.tin_for('own')
      own_spiff = SlimPickins::Library.spiff_for('own', path: File.join(views, 'own.sp'))
      inherited_tin = lib.tin_for('plain')
      inherited_spiff = SlimPickins::Library.spiff_for('plain', path: File.join(views, 'plain.sp'))

      assert_includes own_tin, 'its own chrome'
      assert_includes own_spiff, 'surface own'
      assert_includes inherited_tin, 'link home'
      assert_includes inherited_spiff, 'surface demo'
    end
  end
end
