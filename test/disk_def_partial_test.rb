# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/slim_pickins'

class DiskDefPartialTest < Minitest::Test
  def setup
    @registry_before = SlimPickins::Word.registry.keys
  end

  def teardown
    (SlimPickins::Word.registry.keys - @registry_before).each do |word|
      SlimPickins::Word.registry.delete(word)
    end
  end

  def with_disk_partials(partials)
    Dir.mktmpdir do |dir|
      partials_dir = File.join(dir, 'partials')
      FileUtils.mkdir_p(partials_dir)
      partials.each do |filename, content|
        File.write(File.join(partials_dir, filename), content)
      end
      yield SlimPickins::Library.from(dir)
    end
  end

  def test_disk_def_partial_zero_parameter
    partials = {
      'banner.sp' => <<~SP
        def banner
          note "Welcome to the studio"
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          banner
      SP
      assert_includes html, '<p class="note banner">Welcome to the studio</p>'
    end
  end

  def test_disk_def_partial_single_positional_param
    partials = {
      'greeting.sp' => <<~SP
        def greeting, name
          note .name
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          greeting "Dan"
      SP
      assert_includes html, '<p class="note greeting">Dan</p>'
    end
  end

  def test_disk_def_partial_multiple_positional_params
    partials = {
      'user_badge.sp' => <<~SP
        def user_badge, name, role
          box
            heading .name
            note .role
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          user_badge "Dan", "Admin"
      SP
      assert_includes html, '<h2 class="heading">Dan</h2>'
      assert_includes html, '<p class="note">Admin</p>'
    end
  end

  def test_disk_def_partial_named_arguments_order_independent
    partials = {
      'user_badge.sp' => <<~SP
        def user_badge, name, role
          box
            heading .name
            note .role
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          user_badge role: "Admin", name: "Dan"
      SP
      assert_includes html, '<h2 class="heading">Dan</h2>'
      assert_includes html, '<p class="note">Admin</p>'
    end
  end

  def test_disk_def_partial_mixed_positional_and_named_arguments
    partials = {
      'user_badge.sp' => <<~SP
        def user_badge, name, role
          box
            heading .name
            note .role
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          user_badge "Dan", role: "Admin"
      SP
      assert_includes html, '<h2 class="heading">Dan</h2>'
      assert_includes html, '<p class="note">Admin</p>'
    end
  end

  def test_disk_def_partial_omitted_parameters_default_to_nil
    partials = {
      'user_badge.sp' => <<~SP
        def user_badge, name, role
          box
            heading .name
            choose
              when .role
                note .role
              otherwise
                note "Standard user"
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          user_badge "Dan"
      SP
      assert_includes html, '<h2 class="heading">Dan</h2>'
      assert_includes html, '<p class="note">Standard user</p>'
    end
  end

  def test_disk_def_partial_undeclared_named_arguments_forward_into_chain_scope
    partials = {
      'card_box.sp' => <<~SP
        def card_box, title
          box
            heading .title
            choose
              when .tone
                note .tone
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          card_box "Security Alert", tone: "critical"
      SP
      assert_includes html, '<h2 class="heading">Security Alert</h2>'
      assert_includes html, '<p class="note">critical</p>'
    end
  end

  def test_disk_def_partial_children_block_splicing
    partials = {
      'enclosure.sp' => <<~SP
        def enclosure, title
          box
            heading .title
            children
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          enclosure "Milestone Enclosure"
            note "Nested inside enclosure block"
      SP
      assert_includes html, '<h2 class="heading">Milestone Enclosure</h2>'
      assert_includes html, '<p class="note">Nested inside enclosure block</p>'
    end
  end

  def test_disk_def_partial_with_leading_comments_and_blank_lines
    partials = {
      'tagged_badge.sp' => <<~SP
        # frozen_string_literal: true
        # A component that renders a badge with comment preamble

        def tagged_badge, label
          note .label
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          tagged_badge "Commented"
      SP
      assert_includes html, '<p class="note tagged_badge">Commented</p>'
    end
  end

  def test_disk_def_partial_multiple_defs_in_one_file
    partials = {
      'widgets.sp' => <<~SP
        def widget_header, title
          heading .title

        def widget_footer, footer_text
          note .footer_text
      SP
    }

    with_disk_partials(partials) do |lib|
      html = SlimPickins.render(<<~SP, library: lib)
        page "App"
          widget_header "Header Title"
          widget_footer "Footer Text"
      SP
      assert_includes html, '<h2 class="heading widget_header">Header Title</h2>'
      assert_includes html, '<p class="note widget_footer">Footer Text</p>'
    end
  end
end
