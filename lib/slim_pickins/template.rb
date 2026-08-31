# frozen_string_literal: true

require 'tilt'
require_relative '../slim_pickins'

module SlimPickins
  # A Tilt template, so a `.sp` file renders the way a `.slim` one does.
  #
  # Two things are deliberately not Sinatra's job here. The layout is ours —
  # a layout says `contents`, not `yield`, so Sinatra's own layout machinery
  # is bypassed and `Library` finds `layout.sp` beside the views. And the
  # scope becomes the page's helpers, which is what makes a helper method
  # reachable as `.foo` at the top level.
  class Template < Tilt::Template
    def prepare; end

    def evaluate(scope, locals, &_block)
      SlimPickins.render(data,
                         path: file || '(inline)',
                         locals: locals,
                         helpers: scope,
                         library: library_for(file))
    end

    def self.libraries = @libraries ||= {}

    private

    def library_for(path)
      return nil unless path

      dir = File.dirname(path)
      self.class.libraries[dir] ||= Library.from(dir)
    end
  end

  # Sinatra does not know the extension, so give it the one helper it needs.
  #
  #   class App < Sinatra::Base
  #     helpers SlimPickins::Helpers
  #     get('/') { sp :index, locals: { portfolio: portfolio } }
  #   end
  module Helpers
    def sp(template, options = {}, locals = {})
      render(:sp, template, options.merge(layout: false), locals)
    end
  end
end

Tilt.register(SlimPickins::Template, 'sp')
