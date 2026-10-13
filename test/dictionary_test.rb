# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DictionaryTest < Minitest::Test
  def setup
    @library = SlimPickins::Library.builtin
  end

  def test_block_dispatch_executes_matching_on_block
    account = Struct.new(:status).new(:active)
    builder = SlimPickins::Builder.new(account, @library)

    nodes = builder.capture do
      dictionary(account.status) do
        on :active do
          badge "Active Account"
        end
        on :dormant do
          badge "Dormant Account"
        end
      end
    end

    assert_equal 1, nodes.size
    assert_equal :span, nodes.first.word
    assert_equal "Active Account", nodes.first.attributes[:body]
  end

  def test_block_dispatch_invokes_matching_target_word_and_forwards_arguments
    account = Struct.new(:status).new(:dormant)
    builder = SlimPickins::Builder.new(account, @library)

    nodes = builder.capture do
      dictionary(account.status, "Dormant Notice") do
        on :active, :badge
        on :dormant, :note
      end
    end

    assert_equal 1, nodes.size
    assert_equal :tag, nodes.first.word
    assert_equal :note, nodes.first.attributes[:class_base]
  end

  def test_on_default_acts_as_fallback_when_no_entry_matches
    account = Struct.new(:status).new(:unknown)
    builder = SlimPickins::Builder.new(account, @library)

    nodes = builder.capture do
      dictionary(account.status) do
        on :active do
          badge "Active"
        end
        on :default do
          note "Unrecognized Status"
        end
      end
    end

    assert_equal 1, nodes.size
    assert_equal :tag, nodes.first.word
    assert_equal :note, nodes.first.attributes[:class_base]
  end

  def test_reusable_dictionary_definition_and_map_lookup
    builder = SlimPickins::Builder.new(nil, @library)

    dict = builder.dictionary do
      on :active, :badge
      on :dormant, :note
      on :default, :paragraph
    end

    assert_kind_of SlimPickins::Words::Dictionary, dict

    active_nodes = builder.capture { map(dict, :active, "Active Label") }
    assert_equal 1, active_nodes.size
    assert_equal :span, active_nodes.first.word
    assert_equal "Active Label", active_nodes.first.attributes[:body]

    missing_nodes = builder.capture { map(dict, :pending, "Pending Label") }
    assert_equal 1, missing_nodes.size
    assert_equal :tag, missing_nodes.first.word
  end

  def test_inline_map_with_value_keywords_returns_mapped_value
    builder = SlimPickins::Builder.new(nil, @library)

    result = builder.map(:active, active: "Active Status", dormant: "Dormant Status")
    assert_equal "Active Status", result

    fallback_result = builder.map(:missing, active: "Active", default: "Standard Default")
    assert_equal "Standard Default", fallback_result
  end

  def test_inline_map_with_word_keywords_dispatches_word
    builder = SlimPickins::Builder.new(nil, @library)

    nodes = builder.capture do
      map(:active, "Important Active", active: :badge, dormant: :note)
    end

    assert_equal 1, nodes.size
    assert_equal :span, nodes.first.word
    assert_equal "Important Active", nodes.first.attributes[:body]
  end

  def test_string_and_symbol_key_indifference
    builder = SlimPickins::Builder.new(nil, @library)

    assert_equal "OK", builder.map("active", active: "OK")
    assert_equal "OK", builder.map(:active, "active" => "OK")
  end

  def test_boolean_and_nil_key_indifference
    builder = SlimPickins::Builder.new(nil, @library)

    assert_equal "Yes", builder.map(true, true: "Yes", false: "No")
    assert_equal "Yes", builder.map(true, :true => "Yes", :false => "No")
    assert_equal "No", builder.map(false, true: "Yes", false: "No")
    assert_equal "No", builder.map(false, :true => "Yes", :false => "No")
    assert_equal "None", builder.map(nil, nil: "None", default: "Other")
    assert_equal "None", builder.map(nil, :nil => "None", default: "Other")
  end

  def test_on_cannot_be_called_outside_dictionary
    builder = SlimPickins::Builder.new(nil, @library)

    error = assert_raises(SlimPickins::Error) do
      builder.on(:active, :badge)
    end
    assert_match(/there is no word `on`/, error.message)
  end

  def test_bare_otherwise_acts_as_fallback_inside_dictionary
    account = Struct.new(:status).new(:unrecognized)
    builder = SlimPickins::Builder.new(account, @library)

    nodes = builder.capture do
      dictionary(account.status) do
        on :active do
          badge "Active"
        end
        otherwise do
          note "Otherwise Fallback"
        end
      end
    end

    assert_equal 1, nodes.size
    assert_equal :tag, nodes.first.word
    assert_equal :note, nodes.first.attributes[:class_base]
  end

  def test_full_sp_template_rendering_with_dictionary_and_map
    source = <<~SP
      section account
        dictionary .status
          on active
            badge "Active Account"
          otherwise
            note "Default Note"
        map .status, .label, active: badge, dormant: note
    SP

    ruby = SlimPickins::Transform.call(source)
    account = Struct.new(:status, :label).new(:active, "Status Label")
    page = Struct.new(:account).new(account)
    builder = SlimPickins::Builder.new(page, @library)
    nodes = builder.render(ruby, "template.sp")

    section = nodes.first
    assert_equal :box, section.word
    # Section header choose node + dictionary badge + map badge
    assert_equal 3, section.children.size
    assert_equal :choose, section.children[0].word
    assert_equal :span, section.children[1].word
    assert_equal "Active Account", section.children[1].attributes[:body]
    assert_equal :span, section.children[2].word
    assert_equal "Status Label", section.children[2].attributes[:body]
  end
end
