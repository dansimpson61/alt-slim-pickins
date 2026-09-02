# frozen_string_literal: true

require_relative 'slim_pickins/errors'
require_relative 'slim_pickins/transform'
require_relative 'slim_pickins/contracts'
require_relative 'slim_pickins/compilation'
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
    compilation = Compilation.of(source, path)
    compilation.refuse!(path)
    builder = Builder.new(Page.new(locals: locals, helpers: helpers), library)
    nodes = builder.render(compilation.ruby, path, source: source)
    nodes = filter.call(nodes) if filter
    Generator.new.call(nodes)
  end

  # The semantic tree a page evaluates to, without the HTML. Useful for
  # seeing what a page means — and the tree a second interpreter (an API)
  # would walk.
  def evaluate(source, path: '(page)', locals: {}, helpers: nil, library: nil)
    compilation = Compilation.of(source, path)
    compilation.refuse!(path)
    Builder.new(Page.new(locals: locals, helpers: helpers), library)
           .render(compilation.ruby, path, source: source)
  end

  # The Ruby a page compiles to. Useful for seeing what the transform did.
  def compile(source, path: '(page)')
    Transform.call(source, path: path)
  end

  # An app boots by proving its pages: every top-level view renders against
  # the locals the app gives it, and the first page the app cannot answer
  # raises — naming the line — so a renamed attribute is a boot error, not an
  # eleven-month silence. `layout.sp` is chrome, not a page, and partials are
  # proven through the pages that include them. A view the block answers
  # nothing for is refused, loudly: an unproven page may not boot either.
  #
  #   SlimPickins.prove!(settings.views) do |name|
  #     { scenario: Scenario.defaults, projection: Projection.of(Scenario.defaults) }
  #   end
  def prove!(dir, words: nil, &locals_for)
    library = Library.from(dir, words: words)
    views = Dir[File.join(dir, '*.sp')].sort.reject { |p| File.basename(p) == 'layout.sp' }
    raise Error, "no pages to prove in #{dir}" if views.empty?

    views.each do |path|
      name = File.basename(path, '.sp')
      locals = locals_for.call(name)
      raise Error, "no locals were given to prove `#{name}.sp`" unless locals

      render(File.read(path), path: path, locals: locals, library: library)
      puts "  proved #{name}.sp"
    end
  end
end
