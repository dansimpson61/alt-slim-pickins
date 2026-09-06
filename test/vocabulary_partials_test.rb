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
      assert_includes html, '<p class="flash">Saved.</p>'
    end
  end

  def test_action_is_the_minimal_post_form
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'),
                 %(page p\n  action "Commit", to: "/actions/commit", path: .name, return_to: "/triage", variant: primary\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { name: 'ode-to-joy' } }, library: library_for(dir))
      assert_includes html, '<form class="form" action="/actions/commit" method="post">'
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

  # The named boxes (2026-09-02): footer, aside, list and item are drafted in
  # the language over `box`, which derives its tag from the word — a
  # promoted footer stays a <footer>, classes included.
  def test_the_named_boxes_keep_their_tags
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          aside
            list plain
              item "One"
              item "Two"
          footer "Approximate."
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<aside class="aside">'
      assert_includes html, '<ul class="list list--plain">'
      assert_includes html, '<li class="item">One</li>'
      assert_includes html, '<li class="item">Two</li>'
      assert_includes html, '<footer class="footer">Approximate.</footer>'
    end
  end

  def test_the_box_passes_through_choose
    branch = [:paragraph, {}, []]
    root = SlimPickins::Builder.box_root([[:choose, {}, [branch]]])
    assert_same branch, root
    assert_same branch, SlimPickins::Builder.box_root([branch])
  end

  # The leaf family over the span atom: the Generator owns the formatting the
  # words used to carry — mechanical inference, not the app's judgement.
  def test_the_leaf_family_formats_by_its_word
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          section "Numbers"
            money .amount
            percent .rate
            number .count
            badge warning, "text"
            badge .status
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { amount: 1500, rate: 0.074, count: 3, status: 'ok' } },
                                library: library_for(dir))
      assert_includes html, '<span class="money">$1,500</span>'
      assert_includes html, '<span class="percent">7.4%</span>'
      assert_includes html, '<span class="number">3</span>'
      assert_includes html, '<span class="badge badge--warning">text</span>'
      assert_includes html, '<span class="badge badge--ok">ok</span>'
    end
  end

  # The box's parts derive from the word: a heading inside a box is the box's
  # title, at the box's own level — the part convention, `.section-title`.
  def test_the_boxes_title_themselves
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          section "Held"
            title .deep
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { deep: 'x' } }, library: library_for(dir))
      assert_includes html, '<h2 class="section-title">Held</h2>'
      assert_includes html, '<h3 class="title">x</h3>'
    end
  end

  # `empty` is the situation, not a branch: it renders only while the
  # enclosing subject is an empty collection, and the box keeps its parts.
  def test_empty_renders_only_while_the_subject_is_empty
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          section accounts
            empty "None."
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { accounts: [] } }, library: library_for(dir))
      assert_includes html, '<p class="empty">None.</p>'
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { accounts: ['x'] } }, library: library_for(dir))
      refute_includes html, 'empty'
    end
  end
end
