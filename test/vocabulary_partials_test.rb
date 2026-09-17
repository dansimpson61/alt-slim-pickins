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

  def test_action_inherits_path_and_return_to_from_enclosing_actions_container
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          actions path: .name, return_to: "/triage"
            action "Commit", to: "/actions/commit", variant: primary
            action "Archive", to: "/actions/archive", variant: neutral
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { name: 'ode-to-joy' } }, library: library_for(dir))
      assert_includes html, '<div class="actions">'
      assert_includes html, '<form class="form" action="/actions/commit" method="post">'
      assert_includes html, '<form class="form" action="/actions/archive" method="post">'
      assert_equal 2, html.scan('<input type="hidden" name="path" value="ode-to-joy">').size
      assert_equal 2, html.scan('<input type="hidden" name="return_to" value="/triage">').size
      refute_includes html, 'name="status"'
    end
  end

  def test_action_emits_status_when_specified
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          actions path: .name, return_to: "/triage"
            action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: { name: 'ode-to-joy' } }, library: library_for(dir))
      assert_includes html, '<form class="form" action="/actions/status" method="post">'
      assert_includes html, '<input type="hidden" name="status" value="dormant">'
      assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
      assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
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

  def test_action_standalone_without_contextual_parameters
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Log out", to: "/logout"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<form class="form" action="/logout" method="post">'
      assert_includes html, '<button type="submit" class="button">Log out</button>'
      refute_includes html, 'name="path"'
      refute_includes html, 'name="return_to"'
      refute_includes html, 'name="status"'
    end
  end

  def test_action_with_only_path_modifier
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Delete", to: "/delete", path: "my-file"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<input type="hidden" name="path" value="my-file">'
      refute_includes html, 'name="return_to"'
    end
  end

  def test_action_with_only_return_to_modifier
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Back", to: "/back", return_to: "/home"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<input type="hidden" name="return_to" value="/home">'
      refute_includes html, 'name="path"'
    end
  end

  def test_bare_actions_container_enclosing_action
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          actions
            action "Log out", to: "/logout"
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<div class="actions">'
      assert_includes html, '<form class="form" action="/logout" method="post">'
      refute_includes html, 'name="path"'
      refute_includes html, 'name="return_to"'
    end
  end

  def test_action_does_not_leak_enclosing_model_path
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page article
          action "Like", to: "/like"
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { article: { title: "Joy", path: "/posts/1" } },
                                library: library_for(dir))
      refute_includes html, 'name="path"'
      refute_includes html, '/posts/1'
    end
  end

  def test_action_does_not_leak_sinatra_status_helper
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Save", to: "/save"\n))
      helpers = Object.new
      def helpers.status(_val = nil); 200; end
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, helpers: helpers, library: library_for(dir))
      refute_includes html, 'name="status"'
      refute_includes html, '200'
    end
  end

  def test_generic_custom_container_parameter_inheritance
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'partials'))
      File.write(File.join(dir, 'partials', 'custom_actions.sp'), <<~SP)
        expects children: any, takes: project_id, shape: encloses
        box
          children
      SP
      File.write(File.join(dir, 'partials', 'custom_action.sp'), <<~SP)
        expects takes: content, takes: project_id, shape: encloses
        box
          choose
            when .project_id
              text .project_id
          button .content
      SP
      code = <<~SP
        page p
          custom_actions project_id: "alpha-beta"
            custom_action "Run"
      SP
      html = SlimPickins.render(code, path: 'test.sp', locals: { p: {} }, library: library_for(dir))
      assert_includes html, 'alpha-beta'
    end
  end

  # A partial the Library compiles registers into the shared Word.registry
  # by class name; the tmpdir it lived in is gone when the test ends, so the
  # registered words must go with it. Left behind, they poison a suite
  # sharing one process: StudioDocs memoises its payloads from the live
  # registry, and depending on which class ran first it could memoise
  # `custom_action` with a source_path that no longer exists on disk —
  # "custom_action's partial file is missing", intermittently, by seed.
  # The test world must leave the registry as it found it.
  def teardown
    %i[custom_action custom_actions].each { |word| SlimPickins::Word.registry.delete(word) }
  end
end
