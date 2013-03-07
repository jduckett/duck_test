require 'active_support'
require 'irb' unless defined?(IRB)

module DuckTest
  extend ActiveSupport::Autoload

  # ...
  class Railtie < Rails::Railtie

    puts "DuckTest #{VERSION}"

    config.before_configuration do |app|
      app.config.autoload_paths += AutoloadConfig.new.paths
    end

    config.after_initialize do |app|
      DuckTest::Config.reload!
    end
    
    initializer 'duck_test' do
    
      # $0 holds the name of the ruby file initially loaded by the ruby interpreter.
      # this is basicially preventing the run method from being aliased and overridden if the gem
      # is loaded as the result of running a rake task such as rake test:units
      # if started using a command like: rails c test, then, the following if statement should evaluate to true
      # and re-configure Test::Unit::Runner to alias the run method and check a class variable on DuckTest::FrameWork::Base.ok_to_run
      # if true, the tests should run, otherwise, the tests should not run.  this should prevent tests from running when
      # the console exits.
      if $0 =~ /rails$/
        require 'duck_test/autorun'
      end
    end

    IRB::ExtendCommandBundle.send :include, DuckTest::Console

  end

end
