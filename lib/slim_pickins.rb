# frozen_string_literal: true

require_relative 'slim_pickins/errors'
require_relative 'slim_pickins/transform'
require_relative 'slim_pickins/contracts'
require_relative 'slim_pickins/subject'
require_relative 'slim_pickins/inference'
require_relative 'slim_pickins/library'
require_relative 'slim_pickins/builder'

module SlimPickins
  module_function

  # Render a page written in the language.
  #
  #   SlimPickins.render(File.read("form.sp"), locals: { scenario: inputs })
  def render(source, path: '(page)', locals: {}, helpers: nil, library: nil)
    ruby = Transform.call(source, path: path)
    Builder.new(Page.new(locals: locals, helpers: helpers), library).render(ruby, path)
  end

  # The Ruby a page compiles to. Useful for seeing what the transform did.
  def compile(source, path: '(page)')
    Transform.call(source, path: path)
  end
end
