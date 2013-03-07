$:.push File.expand_path("../lib", __FILE__)

require "duck_test/version"

Gem::Specification.new do |s|

  s.name        = "duck_test"
  s.version     = DuckTest::VERSION

  s.authors     = ["Jeff Duckett"]
  s.email       = ["jeff.duckett@gmail.com"]
  s.homepage    = "http://www.jeffduckett.com/"

  s.summary     = %q{DuckTest runs TestUnit and RSpec tests directly in the IRB console.}
  s.description = %q{DuckTest is a gem that facilitates automated running of TestUnit and RSpec tests directly in the IRB console.  Tests run within a second of being changed.}

  s.require_paths = ["lib"]

  s.files = Dir.glob("lib/**/*")

  s.executables = ["ducktest"]

#  s.platform    = Gem::Platform::RUBY
#  s.required_ruby_version     = '>= 1.9.3'
#  s.required_rubygems_version = ">= 1.8.11"

end
