require 'yaml'

text = <<DOC
this is a test

and I have
no idea

how

the whole thing

will turn out

DOC

content = {maps: text, blacklist: text, whitelist: text, autorun: text}


File.open("/home/jduckett/rails/gems/duck_test/test.yml", 'w') {|f| f.write(YAML.dump(content)) }
