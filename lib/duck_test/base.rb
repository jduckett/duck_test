# DuckTest Base module
require "duck_test/version"

module DuckTest

  autoload :AutoloadConfig, 'duck_test/autoload_config'
  autoload :Config, 'duck_test/config'
  autoload :ConfigHelper, 'duck_test/config_helper'
  autoload :Console, 'duck_test/console'
  autoload :Commands, 'duck_test/commands'
  autoload :DefaultConfig, 'duck_test/default_config'
  autoload :FrameWork, 'duck_test/frame_work/base'
  autoload :Logger, 'duck_test/logger'
  autoload :LoggerHelper, 'duck_test/logger'
  autoload :Platforms, 'duck_test/platforms/base'
  autoload :RunCommands, 'duck_test/run_commands'
  autoload :Usage, 'duck_test/usage'
  autoload :VersionHelper, 'duck_test/version'

  ##################################################################################
  # Executes a configuration block to define watch lists, etc.
  #
  #   DuckTest.config do
  #
  #     runnable "**/*"
  #
  #   end
  #
  # @return [DuckTest::Config] Returns DuckTest::Config instance if a block is passed.
  def self.config(&block)
    config = nil

    if block_given?
      config = DuckTest::Config.new
      config.instance_exec(&block)
      config.class.block_run = true
    end

    return config
  end

end
