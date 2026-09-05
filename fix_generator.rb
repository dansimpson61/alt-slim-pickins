code = File.read("lib/slim_pickins/generator.rb")

code.gsub!(/@out << '<thead>'/, "open_tag('thead')")
code.gsub!(/@out << '<tbody>'/, "open_tag('tbody')")
code.gsub!(/@out << '<tfoot>'/, "open_tag('tfoot')")
code.gsub!(/@out << '<tr>'/, "open_tag('tr')")

File.write("lib/slim_pickins/generator.rb", code)
