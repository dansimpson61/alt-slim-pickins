# frozen_string_literal: true

require_relative 'slim_pickins/errors'
require_relative 'slim_pickins/transform'
require_relative 'slim_pickins/contracts'
require_relative 'slim_pickins/subject'
require_relative 'slim_pickins/inference'
require_relative 'slim_pickins/library'
require_relative 'slim_pickins/generator'
require_relative 'slim_pickins/builder'

module SlimPickins
  module_function

  # Render a page written in the language: evaluate it into a tree of
  # semantic nodes, let an optional filter transform the tree — the AST
  # pipeline's middle stage, exposed — then the Generator interprets it.
  #
  #   SlimPickins.render(File.read("form.sp"), locals: { scenario: inputs },
  #                      filter: ->(tree) { [[:badge, { kind: :ok, label: "12" }, []]] + tree })
  def render(source, path: '(page)', locals: {}, helpers: nil, library: nil, filter: nil)
    ruby = Transform.call(source, path: path)
    builder = Builder.new(Page.new(locals: locals, helpers: helpers), library)
    nodes = builder.render(ruby, path)
    nodes = filter.call(nodes) if filter
    Generator.new.call(nodes)
  end

  # The semantic tree a page evaluates to, without the HTML. Useful for
  # seeing what a page means — and the tree a second interpreter (an API)
  # would walk.
  def evaluate(source, path: '(page)', locals: {}, helpers: nil, library: nil)
    ruby = Transform.call(source, path: path)
    Builder.new(Page.new(locals: locals, helpers: helpers), library).render(ruby, path)
  end

  # The Ruby a page compiles to. Useful for seeing what the transform did.
  def compile(source, path: '(page)')
    Transform.call(source, path: path)
  end
end
