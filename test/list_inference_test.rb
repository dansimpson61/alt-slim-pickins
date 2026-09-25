# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class ListInferenceTest < Minitest::Test
  def test_list_infers_item_for_each_iterations
    source = <<~SP
      page "Documents"
        list
          each doc
            link .name, .path
    SP

    locals = { docs: [{ name: 'README.md', path: '/docs/README.md' },
                      { name: 'ODE.md', path: '/docs/ODE.md' }] }
    html = SlimPickins.render(source, locals: locals)

    assert_includes html, %(<ul class="list">)
    assert_includes html, %(<li class="item"><a href="/docs/README.md" class="link">README.md</a></li>)
    assert_includes html, %(<li class="item"><a href="/docs/ODE.md" class="link">ODE.md</a></li>)
  end

  def test_list_infers_item_for_direct_children
    source = <<~SP
      page "Navigation"
        list
          link "Home", to: "/"
          link "About", to: "/about"
    SP

    html = SlimPickins.render(source)

    assert_includes html, %(<li class="item"><a href="/" class="link">Home</a></li>)
    assert_includes html, %(<li class="item"><a href="/about" class="link">About</a></li>)
  end

  def test_list_preserves_explicit_item_nodes_without_double_wrapping
    source = <<~SP
      page "Palette"
        list
          item
            link "A", to: "/a"
            badge "active"
    SP

    html = SlimPickins.render(source)

    # Should have exactly one <li class="item"> wrapping both link and badge
    assert_equal 1, html.scan(%r{<li class="item">}).size
    assert_includes html, %(<li class="item"><a href="/a" class="link">A</a><span class="badge">active</span></li>)
  end
end
