# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The semantic node, named in DAYTRIP-0.4.0l.
#
# It was a bare three-element Array for the project's first month. The name is
# worth testing because it was taken for two specific reasons, and both are
# properties a later refactor could quietly give back.
class NodeTest < Minitest::Test
  Node = SlimPickins::Node

  def test_a_node_answers_by_name
    node = Node[:box, { class_base: :card }, []]

    assert_equal :box, node.word
    assert_equal :card, node.attributes[:class_base]
    assert_empty node.children
  end

  def test_construction_stays_positional
    assert_equal Node.new(word: :box, attributes: {}, children: []), Node[:box, {}, []],
                 'thirty-one sites build nodes, and a triple reads better than three keywords'
  end

  # Reason one. `body.size == 1 && body.first.is_a?(Array)` was asking "is this
  # one node or a list of them?", which it could not answer, because both were
  # Arrays. `Builder#promote` and `PartialWord` both asked it that way.
  def test_a_node_is_not_a_list_of_nodes
    node = Node[:box, {}, []]

    refute_kind_of Array, node
    assert_kind_of Array, [node]
    assert node.is_a?(Node)
    refute [node].is_a?(Node)
  end

  # Reason two. `Markdown` has its own positional `[:element, open_tag, name,
  # children]` nodes, read with `node[0]` and `node[1]` in the same Generator.
  # Nothing but the surrounding method told them apart.
  def test_a_semantic_node_is_not_a_markdown_node
    refute_equal Node[:element, {}, []], [:element, '<p>', 'p', []]
    refute Node[:element, {}, []].is_a?(Array)
  end

  # A `Data` is frozen, and the runtime has exactly one mutation through a node:
  # `root.attributes[:app_class] = …` in `Builder#promote`, which writes to the
  # hash the node holds. That still works, and rebuilding the node does not.
  def test_a_node_is_frozen_but_the_hash_it_holds_is_not
    node = Node[:box, { class_base: :card }, []]

    assert node.frozen?
    node.attributes[:app_class] = 'portfolio'
    assert_equal 'portfolio', node.attributes[:app_class]
  end

  def test_the_runtime_builds_nodes_and_nothing_else
    tree = SlimPickins.evaluate("page \"x\"\n  heading \"Hello\"\n  list\n    item \"one\"\n",
                                path: 'p.sp', locals: {})
    seen = []
    walk = lambda do |nodes|
      Array(nodes).each do |node|
        next walk.call(node) if node.is_a?(Array)
        next unless node.is_a?(SlimPickins::Node)

        seen << node
        walk.call(node.children)
      end
    end
    walk.call(tree)

    refute_empty seen
    assert_equal %i[page heading], seen.map(&:word).first(2)
  end
end
