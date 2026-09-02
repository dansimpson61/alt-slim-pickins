# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/slim_pickins'

# The vocabulary-as-partials mechanism (Round B1): lib/vocabulary holds the
# language's own new words, drafted in the language itself, and every app
# that loads its library through Library.from gets them — shadowing is
# refused, like any built-in.
class VocabularyPartialsTest < Minitest::Test
  def library_for(dir)
    SlimPickins::Library.from(dir)
  end

  def test_every_app_gets_the_core_vocabulary_partials
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), "page p\n  flash \"Saved.\"\n")
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<p class="note">Saved.</p>'
    end
  end

  def test_action_is_the_minimal_post_form
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'),
                 %(page p\n  action "Commit", to: "/actions/commit", path: .name, return_to: "/triage", variant: primary\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { name: 'ode-to-joy' } }, library: library_for(dir))
      assert_includes html, '<form action="/actions/commit" method="post">'
      assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
      assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
      assert_includes html, '<button type="submit" class="button button--primary">Commit</button>'
    end
  end

  def test_an_app_may_not_redefine_a_vocabulary_partial
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'partials'))
      File.write(File.join(dir, 'partials', 'flash.sp'), "text \"mine\"\n")
      error = assert_raises(SlimPickins::Error) { library_for(dir) }
      assert_match(/`flash` is already a slim-pickins word/, error.message)
    end
  end
end
