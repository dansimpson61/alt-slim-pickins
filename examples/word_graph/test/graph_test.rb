# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/graph'

class GraphTest < Minitest::Test
  def setup
    @graph = WordGraph::Graph.new
  end

  def test_graph_loads_all_64_words
    assert_equal 64, @graph.all.size
    assert_equal 64, @graph.stats['total_words']
    assert_equal 7, @graph.stats['total_shapes']
    assert_equal 59, @graph.stats['nouns_count']
    assert_equal 5, @graph.stats['non_nouns_count']
  end

  def test_shapes_distribution_totals_64
    shapes = @graph.shapes
    assert_equal 7, shapes.size
    total_in_shapes = shapes.sum(&:count)
    assert_equal 64, total_in_shapes

    # Ensure all shapes have descriptions and formatters
    shapes.each do |point|
      refute_empty point.name
      refute_empty point.description
      assert_equal :number, point.format_for(:count)
      assert_equal 'Count', point.label_for(:count)
    end
  end

  def test_explicit_containment_edges
    table = @graph.find('table')
    assert table
    assert table.is_gatherer
    assert_includes table.explicit_children, :column
    assert_includes table.explicit_children, :total

    column = @graph.find('column')
    assert column
    assert column.is_register
    assert_includes column.explicit_parents, :table

    chart = @graph.find('chart')
    assert chart
    assert_includes chart.explicit_children, :band
    assert_includes chart.explicit_children, :line
    assert_includes chart.explicit_children, :level

    band = @graph.find('band')
    assert band
    assert_includes band.explicit_parents, :chart

    choice = @graph.find('choice')
    assert choice
    assert_includes choice.explicit_children, :option

    option = @graph.find('option')
    assert option
    assert_includes option.explicit_parents, :choice

    choose = @graph.find('choose')
    assert choose
    assert_includes choose.explicit_children, :when
    assert_includes choose.explicit_children, :otherwise

    when_node = @graph.find('when')
    assert when_node
    assert_includes when_node.explicit_parents, :choose
  end

  def test_control_flow_and_parts_of_speech
    each_node = @graph.find('each')
    assert each_node
    assert_equal :determiner, each_node.speech
    assert_equal :iterates, each_node.shape
    assert each_node.is_control
    refute each_node.is_noun

    choose_node = @graph.find('choose')
    assert choose_node
    assert_equal :verb, choose_node.speech
    assert choose_node.is_control

    assert_equal 5, @graph.control_words.size
    assert_equal 4, @graph.gatherers.size
    assert_equal 7, @graph.registers.size
  end

  def test_search_and_filters
    table_search = @graph.search('table')
    assert_includes table_search.map(&:name), :table
    assert_includes table_search.map(&:name), :column

    gathers = @graph.by_shape(:gathers)
    assert_equal 4, gathers.size
    assert_equal %i[chart choice choose table], gathers.map(&:name).sort

    registers = @graph.by_shape(:registers)
    assert_equal 7, registers.size
    assert_equal %i[band column item level line option total], registers.map(&:name).sort
  end

  def test_serialization_to_h
    node = @graph.find('table')
    data = node.to_h
    assert_equal 'table', data['name']
    assert_equal 'gathers', data['shape']
    assert_equal 'noun', data['speech']
    assert_equal true, data['is_gatherer']
    assert data['in_degree'].is_a?(Integer)
    assert data['out_degree'].is_a?(Integer)
    assert data['connections_count'].is_a?(Integer)
  end
end
