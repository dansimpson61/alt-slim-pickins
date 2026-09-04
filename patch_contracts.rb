code = File.read("lib/slim_pickins/contracts.rb")

new_contracts = <<-RUBY
    button:     Contract.new(name: :variant, content: true, modifiers: %i[to type size], shape: :says),
    iframe:     Contract.new(name: :name, modifiers: %i[src srcdoc width height], shape: :presents),
    sidebar:    Contract.new(children: :any, shape: :encloses),
    split_pane: Contract.new(children: :any, shape: :encloses),
    sidebar_layout: Contract.new(children: :any, shape: :encloses)
RUBY

code.sub!(/button:\s+Contract.new\(name: :variant, content: true, modifiers: %i\[to type size\], shape: :says\)/, new_contracts.strip)
File.write("lib/slim_pickins/contracts.rb", code)
