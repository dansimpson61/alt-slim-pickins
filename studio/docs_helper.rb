require 'ostruct'
module StudioDocs
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
