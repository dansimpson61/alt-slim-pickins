# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DefTest < Minitest::Test
  Doc = Struct.new(:name, :path, :content, keyword_init: true)

  def render(source, **options)
    SlimPickins.render(source, path: '(test)', **options)
  end

  def test_zero_parameter_def
    source = <<~SP
      page "App"
        banner

      def banner
        note "Welcome to the studio"
    SP
    html = render(source)
    assert_includes html, '<p class="note">Welcome to the studio</p>'
  end

  def test_single_parameter_def
    source = <<~SP
      page "App"
        greeting "Dan"

      def greeting, name
        note .name
    SP
    html = render(source)
    assert_includes html, '<p class="note">Dan</p>'
  end

  def test_multiple_parameters_positional_binding
    source = <<~SP
      page "App"
        user_badge "Dan", "Admin"

      def user_badge, name, role
        box
          heading .name
          note .role
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Dan</h2>'
    assert_includes html, '<p class="note">Admin</p>'
  end

  def test_named_arguments_binding_order_independent
    source = <<~SP
      page "App"
        user_badge role: "Admin", name: "Dan"

      def user_badge, name, role
        box
          heading .name
          note .role
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Dan</h2>'
    assert_includes html, '<p class="note">Admin</p>'
  end

  def test_mixed_positional_and_named_arguments
    source = <<~SP
      page "App"
        user_badge "Dan", role: "Admin"

      def user_badge, name, role
        box
          heading .name
          note .role
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Dan</h2>'
    assert_includes html, '<p class="note">Admin</p>'
  end

  def test_omitted_declared_parameters_default_to_nil
    source = <<~SP
      page "App"
        user_badge "Dan"

      def user_badge, name, role
        box
          heading .name
          choose
            when .role
              note .role
            otherwise
              note "Standard user"
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Dan</h2>'
    assert_includes html, '<p class="note">Standard user</p>'
  end

  def test_undeclared_named_arguments_forward_into_chain_scope
    source = <<~SP
      page "App"
        card_box "Title", theme: "dark"

      def card_box, title
        box
          heading .title
          note .theme
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Title</h2>'
    assert_includes html, '<p class="note">dark</p>'
  end

  def test_hoisting_allows_def_before_or_after_page
    before_source = <<~SP
      def banner
        note "Hello"

      page "App"
        banner
    SP
    after_source = <<~SP
      page "App"
        banner

      def banner
        note "Hello"
    SP
    assert_equal render(before_source), render(after_source)
  end

  def test_child_splicing_with_caller_block
    source = <<~SP
      page "App"
        enclosure "Custom Box"
          note "Inside enclosure"

      def enclosure, title
        box
          heading .title
          children
    SP
    html = render(source)
    assert_includes html, '<h2 class="heading">Custom Box</h2>'
    assert_includes html, '<p class="note">Inside enclosure</p>'
  end

  def test_flexible_link_with_positional_arguments
    source = <<~SP
      page "App"
        link "Docs", "/documentation"
        link .doc_name, .doc_path
    SP
    html = render(source, locals: { doc_name: "Guide", doc_path: "/guide" })
    assert_includes html, '<a href="/documentation" class="link">Docs</a>'
    assert_includes html, '<a href="/guide" class="link">Guide</a>'
  end

  def test_doc_reader_specimen_populated_state
    source = <<~SP
      page "Doc Reader"
        sidebar docs, "Documents"
        reading_pane selected_doc

      def sidebar, documents, title
        box documents, title
          empty "No markdown documents in ~/dev/alt-slim-pickins."
          list documents
            each document
              link .name, .path

      def reading_pane, document
        box document, .name
          empty "No document selected."
          prose markdown, .content
    SP

    docs = [
      Doc.new(name: "README.md", path: "/docs/README.md", content: "# Welcome\nSlim-pickins docs."),
      Doc.new(name: "ODE.md", path: "/docs/ODE.md", content: "# Ode\nJoyful code.")
    ]
    html = render(source, locals: { docs: docs, selected_doc: docs.first })

    assert_includes html, '<h2 class="heading">Documents</h2>'
    assert_includes html, '<a href="/docs/README.md" class="link">README.md</a>'
    assert_includes html, '<a href="/docs/ODE.md" class="link">ODE.md</a>'
    assert_includes html, '<h2 class="heading">README.md</h2>'
    assert_includes html, '<div class="prose"><h2>Welcome</h2><p>Slim-pickins docs.</p></div>'
    refute_includes html, 'No markdown documents'
    refute_includes html, 'No document selected'
  end

  def test_doc_reader_specimen_empty_doc_state
    source = <<~SP
      page "Doc Reader"
        sidebar docs, "Documents"
        reading_pane selected_doc

      def sidebar, documents, title
        box documents, title
          empty "No markdown documents in ~/dev/alt-slim-pickins."
          list documents
            each document
              link .name, .path

      def reading_pane, document
        box document, .name
          empty "No document selected."
          prose markdown, .content
    SP

    docs = [Doc.new(name: "README.md", path: "/docs/README.md", content: "# Welcome")]
    html = render(source, locals: { docs: docs, selected_doc: nil })

    assert_includes html, '<h2 class="heading">Documents</h2>'
    assert_includes html, '<a href="/docs/README.md" class="link">README.md</a>'
    assert_includes html, '<p class="empty">No document selected.</p>'
    refute_includes html, 'class="prose"'
  end

  def test_doc_reader_specimen_empty_all_state
    source = <<~SP
      page "Doc Reader"
        sidebar docs, "Documents"
        reading_pane selected_doc

      def sidebar, documents, title
        box documents, title
          empty "No markdown documents in ~/dev/alt-slim-pickins."
          list documents
            each document
              link .name, .path

      def reading_pane, document
        box document, .name
          empty "No document selected."
          prose markdown, .content
    SP

    html = render(source, locals: { docs: [], selected_doc: nil })

    assert_includes html, '<h2 class="heading">Documents</h2>'
    assert_includes html, '<p class="empty">No markdown documents in ~/dev/alt-slim-pickins.</p>'
    assert_includes html, '<p class="empty">No document selected.</p>'
    refute_includes html, 'class="list"'
    refute_includes html, 'class="prose"'
  end
end
