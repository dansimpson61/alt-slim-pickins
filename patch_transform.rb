code = File.read("lib/slim_pickins/transform.rb")
code.sub!(/DOTTED\s*=\s*\/.+/, "DOTTED  = /\\A\\.([a-z_][a-z0-9_-]*\\??)\\z/")
code.sub!(/BINDING\s*=\s*\/.+/, "BINDING = /\\A[a-z_][a-z0-9_-]*(\\.[a-z0-9_-]+\\??)+\\z/")

new_dotted = <<-RUBY
when DOTTED
        method = Regexp.last_match(1)
        method.include?('-') ? "subject.public_send(:'\#{method}')" : "subject.\#{method}"
RUBY
code.sub!(/when DOTTED.+/, new_dotted.strip)

new_binding = <<-RUBY
when BINDING
        arg.split('.').map { |p| p.include?('-') ? "public_send(:'\#{p}')" : p }.join('.')
RUBY
code.sub!(/when BINDING.+/, new_binding.strip)

File.write("lib/slim_pickins/transform.rb", code)
