# frozen_string_literal: true

require_relative '../../../lib/slim_pickins'
require_relative '../../../lib/slim_pickins/conventions'

module WordGraph
  # A structural point for shape distribution visualizations.
  ShapePoint = Struct.new(:name, :count, :shape, :description, keyword_init: true) do
    SHAPE_DESCRIPTIONS = {
      encloses: 'Structural containers that hold child words and define layout boundaries.',
      presents: 'Visual leaf elements displaying formatted content, text, numbers, and dates.',
      says: 'Interactive and semantic leaves saying actions, inputs, and state.',
      registers: 'Subordinate words declaring columns, series, options, or items to a gatherer.',
      document: 'Root layout chrome, page headers, scripts, and stylesheets.',
      gathers: 'Orchestrating words collecting child registrations into composite structures.',
      iterates: 'Control flow iterating over collections and rebinding subjects.'
    }.freeze

    def self.build(shape, count)
      new(
        name: shape.to_s.capitalize,
        count: count,
        shape: shape,
        description: SHAPE_DESCRIPTIONS.fetch(shape, '')
      )
    end

    def label_for(attr)
      attr.to_s.capitalize
    end

    def format_for(attr)
      attr == :count ? :number : :text
    end

    def to_h
      {
        'name' => name,
        'count' => count,
        'shape' => shape.to_s,
        'description' => description
      }
    end
  end

  # A node representing a single word in the 64-word vocabulary and its graph connections.
  class Node
    attr_reader :name, :shape, :speech, :subject_flow, :parents_decl, :children_decl,
                :modifiers, :infers, :gathers, :empty, :id_flag, :label_flag, :content_flag,
                :explicit_parents, :explicit_children

    def initialize(name:, contract:)
      @name = name.to_sym
      @shape = contract.shape
      @speech = contract.speech
      @subject_flow = contract.subject
      @parents_decl = contract.parents
      @children_decl = contract.children
      @modifiers = (contract.modifiers + SlimPickins::Contracts::UNIVERSAL_MODIFIERS).uniq.sort
      @infers = (contract.infers || []).dup.sort
      @gathers = contract.gathers || (@shape == :gathers)
      @empty = contract.empty || false
      @id_flag = contract.id || false
      @label_flag = contract.label || false
      @content_flag = contract.content || false

      @explicit_parents = []
      @explicit_children = []
    end

    # Graph linking
    def link_relations!(all_contracts)
      # 1. From parents declaration
      if @parents_decl.is_a?(Array)
        @parents_decl.each do |p|
          @explicit_parents << p unless @explicit_parents.include?(p)
        end
      end

      # 2. From children declaration
      if @children_decl.is_a?(Array)
        @children_decl.each do |c|
          @explicit_children << c unless @explicit_children.include?(c)
        end
      end

      # 3. From other words pointing to us
      all_contracts.each do |other_name, other_contract|
        other_sym = other_name.to_sym
        if other_contract.parents.is_a?(Array) && other_contract.parents.include?(@name)
          @explicit_children << other_sym unless @explicit_children.include?(other_sym)
        end
        if other_contract.children.is_a?(Array) && other_contract.children.include?(@name)
          @explicit_parents << other_sym unless @explicit_parents.include?(other_sym)
        end
      end

      @explicit_parents.sort!
      @explicit_children.sort!
    end

    # Graph degree metrics
    def in_degree
      @explicit_parents.size
    end

    def out_degree
      @explicit_children.size
    end

    def conventions_count
      @infers.size
    end

    def modifiers_count
      @modifiers.size
    end

    def connections_count
      in_degree + out_degree + conventions_count
    end

    # Un-predicated attributes for view conditionals and tables (avoiding G12 trap)
    def word_name
      @name.to_s
    end

    def shape_name
      @shape.to_s
    end

    def speech_name
      @speech.to_s
    end

    def subject_name
      @subject_flow.to_s
    end

    def is_noun
      @speech == :noun
    end

    def is_gatherer
      @gathers || (@shape == :gathers)
    end

    def is_register
      @shape == :registers
    end

    def is_control
      @speech != :noun
    end

    def is_leaf
      @children_decl == :none
    end

    def is_container
      %i[encloses gathers iterates document].include?(@shape)
    end

    def has_explicit_parents
      @explicit_parents.any?
    end

    def has_explicit_children
      @explicit_children.any?
    end

    def has_conventions
      @infers.any?
    end

    def shape_badge
      case @shape
      when :gathers then 'ok'
      when :registers then 'neutral'
      when :encloses then 'ok'
      when :iterates then 'warning'
      when :document then 'neutral'
      when :presents then 'neutral'
      when :says then 'neutral'
      else 'neutral'
      end
    end

    def speech_badge
      case @speech
      when :noun then 'neutral'
      when :verb then 'warning'
      when :conjunction then 'warning'
      when :adverb then 'warning'
      when :determiner then 'ok'
      when :adjective then 'neutral'
      else 'neutral'
      end
    end

    def parents_summary
      if @explicit_parents.any?
        @explicit_parents.map(&:to_s).join(', ')
      elsif @parents_decl == :any
        'any container'
      else
        'none'
      end
    end

    def children_summary
      if @explicit_children.any?
        @explicit_children.map(&:to_s).join(', ')
      elsif @children_decl == :any
        'any element'
      elsif @children_decl == :none
        'none (leaf)'
      else
        @children_decl.to_s
      end
    end

    def modifiers_summary
      @modifiers.map(&:to_s).join(', ')
    end

    def conventions_summary
      if @infers.any?
        @infers.map(&:to_s).join(', ')
      else
        'none'
      end
    end

    def label_for(attr)
      case attr
      when :speech_name then 'Part of Speech'
      when :subject_name then 'Subject Shift'
      when :parents_summary then 'Parents'
      when :children_summary then 'Children'
      when :conventions_summary then 'Conventions'
      when :modifiers_summary then 'Modifiers'
      when :word_name, :name then 'Word'
      when :shape_name, :shape then 'Shape'
      when :connections_count then 'Connections'
      when :in_degree then 'In-degree'
      when :out_degree then 'Out-degree'
      else attr.to_s.split('_').map(&:capitalize).join(' ')
      end
    end

    def format_for(attr)
      case attr
      when :connections_count, :in_degree, :out_degree, :modifiers_count, :conventions_count
        :number
      else
        :text
      end
    end

    def to_h
      {
        'name' => word_name,
        'word_name' => word_name,
        'shape' => shape_name,
        'shape_name' => shape_name,
        'speech' => speech_name,
        'speech_name' => speech_name,
        'subject' => subject_name,
        'subject_name' => subject_name,
        'in_degree' => in_degree,
        'out_degree' => out_degree,
        'connections_count' => connections_count,
        'conventions_count' => conventions_count,
        'modifiers_count' => modifiers_count,
        'parents_summary' => parents_summary,
        'children_summary' => children_summary,
        'modifiers_summary' => modifiers_summary,
        'conventions_summary' => conventions_summary,
        'is_noun' => is_noun,
        'is_gatherer' => is_gatherer,
        'is_register' => is_register,
        'is_control' => is_control,
        'is_leaf' => is_leaf,
        'is_container' => is_container,
        'has_explicit_parents' => has_explicit_parents,
        'has_explicit_children' => has_explicit_children,
        'has_conventions' => has_conventions,
        'shape_badge' => shape_badge,
        'speech_badge' => speech_badge,
        'explicit_parents' => @explicit_parents.map(&:to_s),
        'explicit_children' => @explicit_children.map(&:to_s),
        'modifiers' => @modifiers.map(&:to_s),
        'infers' => @infers.map(&:to_s)
      }
    end
  end

  # The repository and graph analyzer for all 64 words.
  class Graph
    attr_reader :nodes, :contracts

    def self.instance
      @instance ||= new
    end

    def self.load
      instance
    end

    def self.vocabulary_words
      @vocabulary_words ||= begin
        ruby_words = SlimPickins::Words.constants.map { |c| SlimPickins::Words.const_get(c) }
                      .select { |k| k.is_a?(Class) && k < SlimPickins::Word }
                      .map { |k| k.name.split('::').last.downcase.to_sym }
        vocab_dir = File.expand_path('../../../lib/vocabulary', __dir__)
        sp_words = Dir[File.join(vocab_dir, '*.sp')].map { |p| File.basename(p, '.sp').to_sym }
        (ruby_words + sp_words).uniq.sort
      end
    end

    def initialize
      SlimPickins::Library.builtin
      @contracts = SlimPickins::CONTRACTS
      words = self.class.vocabulary_words

      @nodes = words.to_h do |word|
        [word, Node.new(name: word, contract: @contracts[word])]
      end

      # Establish graph edges
      @nodes.each_value do |node|
        node.link_relations!(@contracts)
      end
    end

    def all
      @nodes.values.sort_by(&:name)
    end

    def find(name)
      return nil if name.nil? || name.empty?
      @nodes[name.to_sym]
    end

    def by_shape(shape)
      target = shape.to_sym
      all.select { |n| n.shape == target }
    end

    def by_speech(speech)
      target = speech.to_sym
      all.select { |n| n.speech == target }
    end

    def search(query)
      return all if query.nil? || query.strip.empty?
      q = query.downcase.strip
      all.select do |n|
        n.word_name.include?(q) ||
          n.shape_name.include?(q) ||
          n.speech_name.include?(q) ||
          n.infers.any? { |c| c.to_s.include?(q) } ||
          n.modifiers.any? { |m| m.to_s.include?(q) }
      end
    end

    def shapes
      shapes_order = %i[encloses presents says registers document gathers iterates]
      counts = all.group_by(&:shape).transform_values(&:size)
      shapes_order.map do |s|
        ShapePoint.build(s, counts[s] || 0)
      end
    end

    def gatherers
      all.select(&:is_gatherer)
    end

    def registers
      all.select(&:is_register)
    end

    def control_words
      all.select(&:is_control)
    end

    def stats
      {
        'total_words' => all.size,
        'total_shapes' => shapes.size,
        'nouns_count' => all.count(&:is_noun),
        'non_nouns_count' => all.count(&:is_control),
        'gatherers_count' => gatherers.size,
        'registers_count' => registers.size,
        'total_conventions' => SlimPickins::Conventions::ALL.size,
        'explicit_edges_count' => all.sum(&:in_degree)
      }
    end
  end
end
