# frozen_string_literal: true

require_relative 'word'

module SlimPickins
  class PartialWord < Word
    class << self
      attr_accessor :compilation, :source_lines, :is_builtin, :partial_name
    end

    def evaluate
      self.class.compilation.refuse!("partials/#{self.class.partial_name}.sp")
      name, content = arguments(@args)
      contract = self.class.instance_variable_get(:@contract)
      
      # We no longer need to parse the contract here!
      # We just check the complaint!
      complaint = contract && Contracts.call_complaint(contract, self.class.partial_name,
                                           name.nil? ? [] : [name],
                                           content.nil? ? [] : [content],
                                           @kwargs.keys)
      raise Error, complaint if complaint

      parameters = parameters_for(contract, name, content, @kwargs)
ruby_ast = self.class.compilation.ruby
p_name = self.class.partial_name
p_lines = self.class.source_lines
b_inst = @builder
      evaluate_proc = -> { b_inst.send(:capture) { b_inst.send(:eval_with, ruby_ast, "partials/#{p_name}.sp", p_lines) } }

      
shifts = contract.nil? ? true : contract.name == :subject
push = !contract.nil? || @kwargs.any? || !content.nil? || (!shifts && !name.nil?)

      
      body_block = lambda do
        if contract&.gathers
          with_open
          collected = @collected
          # We need to splice the collected items
          with_splice(collected.flatten(1)) { evaluate_body(evaluate_proc, parameters, self.class.partial_name, push, contract) }
        elsif contract&.inside && contract&.inside != :any
          target = open_gatherer_named(contract&.inside)
          raise Error, "#{self.class.partial_name} belongs inside a #{contract&.inside}" unless target

          nodes = evaluate_body(evaluate_proc, parameters, self.class.partial_name, push, contract)
          target.collect(nodes)
          nodes
        else
          with_splice(prune(capture(&@block), empty_active?)) do
            evaluate_body(evaluate_proc, parameters, self.class.partial_name, push, contract)
          end
        end
      end

      value, empty, body =
        if shifts
          about(name, &body_block)
        elsif contract&.empty && !empty_active?
          [nil, false, []]
        else
          [nil, false, body_block.call]
        end

      if body.size == 1 && body.first.is_a?(Array)
        box = Builder.box_root(body)[1]
        if self.class.is_builtin
          box[:class_base] = self.class.partial_name
        else
          box[:app_class] = self.class.partial_name
        end
      end

      emit_node(body.first) if body.size == 1 && !(contract&.inside && contract&.inside != :any)
      body.each { |n| emit_node(n) } if body.size > 1 && !(contract&.inside && contract&.inside != :any)
      
      value
    end

    private

    def parameters_for(contract, name, content, kwargs)
      return { content: content, name: name }.merge(kwargs) unless contract
      declared = {}
      contract.modifiers.each { |modifier| declared[modifier] = kwargs[modifier] }
      declared[:name] = name if contract.name != :none
      declared[:content] = content if contract.content
      contract.modifiers.each { |modifier| declared[modifier] = kwargs[modifier] }
      declared[:id] = @builder.send(:card_id) if contract.id
      declared[:label] = label_for(name, content) if contract.label
      declared
    end

    def evaluate_body(evaluate_proc, parameters, word, push, contract)
      if push
        chain.with(parameters, described_as: "this #{word}", overlay: !contract.nil?) { evaluate_proc.call }
      else
        evaluate_proc.call
      end
    end

    def open_gatherer_named(word)
      @builder.send(:open_gatherer_named, word)
    end

    def with_splice(nodes, &block)
      @builder.send(:with_splice, nodes, &block)
    end
    
    def empty_active?
      @builder.send(:empty_active?)
    end
  end
end
