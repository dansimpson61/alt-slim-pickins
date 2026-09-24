# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class PrivilegedTagTest < Minitest::Test
  def teardown
    SlimPickins::Compilation.clear!
  end

  def test_app_page_using_tag_is_refused
    source = "page \"Unprivileged\"\n  tag div, class: \"bad\"\n"
    error = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.render(source, path: 'test_app.sp')
    end
    assert_includes error.message, '`tag` is a privileged primitive and may not be used in app pages'
    assert_includes error.message, 'test_app.sp, line 2'
  end

  def test_privileged_compilation_permits_tag
    source = "tag div, class: \"ok\"\n  tag span, \"hello\"\n"
    compilation = SlimPickins::Compilation.of(source, 'lib/vocabulary/custom.sp', privileged: true)
    refute compilation.instance_variable_get(:@violation), 'Privileged compilation must have no violations for tag'
  end

  def test_cache_isolates_privileged_from_unprivileged_compilation
    source = "tag div, \"content\"\n"
    # Privileged compilation caches with privileged: true
    privileged_comp = SlimPickins::Compilation.of(source, 'lib/vocabulary/custom.sp', privileged: true)
    refute privileged_comp.instance_variable_get(:@violation)

    # Unprivileged compilation of the identical source must not reuse privileged compilation
    unprivileged_comp = SlimPickins::Compilation.of(source, 'app_page.sp', privileged: false)
    assert unprivileged_comp.instance_variable_get(:@violation), 'Unprivileged compilation must record tag violation'
    assert_includes unprivileged_comp.instance_variable_get(:@violation).complaint,
                    '`tag` is a privileged primitive and may not be used in app pages'
  end

  def test_builder_tag_renders_positional_content_and_kwargs
    builder = SlimPickins::Builder.new({})
    node = builder.tag(:p, 'Hello world', class: 'lead', id: 'intro')
    html = SlimPickins::Generator.new.call([node])
    assert_equal "<p class=\"lead\" id=\"intro\">Hello world</p>\n", html
  end

  def test_builder_tag_renders_nested_block_children
    builder = SlimPickins::Builder.new({})
    node = builder.tag(:details, open: true) do
      builder.tag(:summary, 'More info')
      builder.tag(:p, 'Details here')
    end
    html = SlimPickins::Generator.new.call([node])
    expected = "<details open>\n  <summary>More info</summary><p>Details here</p>\n</details>\n"
    assert_equal expected, html
  end

  def test_builder_tag_supports_void_elements
    builder = SlimPickins::Builder.new({})
    node = builder.tag(:img, src: '/logo.png', alt: 'Logo')
    html = SlimPickins::Generator.new.call([node])
    assert_equal "<img src=\"/logo.png\" alt=\"Logo\">\n", html
  end
end
