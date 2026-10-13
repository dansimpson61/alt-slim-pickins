# frozen_string_literal: true

require_relative 'lib/slim_pickins/version'

Gem::Specification.new do |spec|
  spec.name = 'slim_pickins'
  spec.version = SlimPickins::VERSION
  spec.authors = ['Dan Simpson']
  spec.email = ['dansimpson61@gmail.com']

  spec.summary = 'A view DSL whose grammar stays describable all the way down'
  spec.description = 'A pure-Ruby view language with one-sentence grammar, 64 canonical words, Spiff stylesheets, and zero runtime dependencies.'
  spec.homepage = 'https://github.com/dansimpson61/alt-slim-pickins'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    Dir['lib/**/*', 'README.md', 'docs/**/*']
      .select { |f| File.file?(f) }
  end
  spec.require_paths = ['lib']
end
