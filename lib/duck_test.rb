# loads all of the source code files used by the gem.
module DuckTest
  require "duck_test/base"
  require "duck_test/platforms/dependencies"
  require "duck_test/railtie" if defined?(Rails)
end
