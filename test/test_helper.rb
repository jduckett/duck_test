ENV["RAILS_ENV"] = "test"
$:.unshift File.dirname(__FILE__)

require "dev.com/config/environment"
require "rails/test_help"

# this makes "rake test" possible from the gem root directory
require "duck_test"
require "test_files"

TestFiles.setup
