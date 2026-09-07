require 'ostruct'
module StudioDocs
  # One link in the sidebar. A plain Struct is the app contract satisfied with
  # no ceremony, which is the point — `each word` binds one of these and the
  # view reads `.name` and `.path` off it.
  Entry = Struct.new(:name, :path, keyword_init: true)

  # The documents worth reading end to end, in the order a newcomer should
  # meet them. Curated rather than globbed: not every `.md` at the root is a
  # guide, and the order is part of the argument.
  GUIDES = %w[PRIMER VOCABULARY CONTRACT DESIGN KERNEL LORE
              design_conventions].freeze

  def self.guides = GUIDES.map { |name| Entry.new(name: name, path: "/guides/#{name}") }

  # The studio's own partials register as words too — `editor`, `preview`,
  # `split_pane`. They are this app's furniture, not the language, so the
  # sidebar leaves them out. Named explicitly rather than relying on being
  # read before the studio's library loads, which would be true today and
  # silently false the first time a line moved.
  FURNITURE = Dir[File.join(__dir__, 'views', 'partials', '*.sp')]
              .map { |f| File.basename(f, '.sp') }.freeze

  # Every word the language actually knows. The sidebar used to be 77
  # hand-written `link` sentences, which could disagree with the vocabulary
  # and had no way to say so. Read from the registry, it cannot.
  def self.words
    require_relative '../lib/slim_pickins'
    SlimPickins::Library.builtin
    (SlimPickins::Word.registry.keys.map(&:to_s) - FURNITURE).sort
      .map { |word| Entry.new(name: word, path: "/docs/#{word}") }
  end

  def self.build
    require_relative '../lib/slim_pickins'
    SlimPickins::Library.builtin
    
    docs = {}
    SlimPickins::Word.registry.each do |name, klass|
      word = name.to_s
      
      contract = SlimPickins::CONTRACTS[word.to_sym]
      contract_md = if contract
        SlimPickins::Contracts.bullets(word, contract).join("\n")
      else
        "No explicit contract defined."
      end
      
      impl = if klass.respond_to?(:partial_name)
        file = "lib/vocabulary/#{word}.sp"
        source = File.read(file) rescue "Source not found"
        "**Type:** App Partial\n(`#{word}.sp`)\n\n**Defined in**\n`#{file}`\n\n```sp\n#{source.strip}\n```"
      else
        source_loc = klass.instance_method(:evaluate).source_location rescue nil
        source_loc ||= klass.instance_method(:initialize).source_location rescue nil
        source_loc ||= klass.methods(false).map { |m| klass.method(m).source_location }.compact.first rescue nil
        
        file, line = source_loc
        if file
          file = file.sub(Dir.pwd + '/', '')
          lines = File.readlines(file)
          
          # Find the class declaration by walking backwards from the method definition
          class_start_line = line - 1
          while class_start_line > 0 && lines[class_start_line] !~ /^(\s*)class #{klass.name.split('::').last}/
            class_start_line -= 1
          end
          
          class_lines = []
          if class_start_line >= 0 && lines[class_start_line] =~ /^(\s*)class #{klass.name.split('::').last}/
            class_indent = $1.length
            lines[class_start_line..-1].each do |l|
              class_lines << l
              break if l =~ /^#{" " * class_indent}end/
            end
          end
          
          if class_lines.any?
            "**Type:** Ruby Class\n(`#{klass.name}`)\n\n**Defined in**\n`#{file}:#{class_start_line + 1}`\n\n```ruby\n#{class_lines.join.strip}\n```"
          else
            "**Type:** Ruby Class\n(`#{klass.name}`)\n\n**Defined in**\n`#{file}:#{line}`"
          end
        else
          "**Type:** Ruby Class\n(`#{klass.name}`)\n\n**Defined in**\nUnknown location"
        end
      end
      
      docs[word] = OpenStruct.new(contract: contract_md, implementation: impl)
    end
    OpenStruct.new(docs)
  end
end
