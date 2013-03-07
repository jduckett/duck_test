module DuckTest

  ##################################################################################
  # Helper methods for configuring autoload paths during startup.  One of the requirements essential to running tests in the console
  # is making all of the module and class files visible to the console environment.  Typically, this is accomplished via config/application.rb
  # by adding to the autoload_paths like the following:
  #
  #    config.autoload_paths += %W(#{Rails.root}/test)
  #
  # During startup DuckTest will attempt to take this step for you prior to configuration using a before_configuration block inside
  # the Railtie class for the gem.  You can guide this behavior in a couple of ways using a config file in two locations.
  #
  # - In the home directory of your file system: ~/.ducktestrc
  # - In the root directory of your Rails application: Rails.root/.ducktest
  #
  # Notice the slight difference in the file names.  One with rc and one without.  The default configuration is to load each directory for
  # each supported testing framework if the directory exists.  Currently, testunit and rspec are the two testing frameworks.
  # The startup process goes something like this:
  #
  # 1. load configuration settings from disk
  # 2. determine the current Rails environment: test, development, production.
  # 3. loop thru each directory from the config.  if the directory is configured to be added to the autoload_path and
  #    the directory actually exists, then, it is added, otherwise, it is ignored.
  #
  # The following is a sample config file.
  #    ---
  #    test:          # represents the Rails environment
  #      test: true   # represents an app directory directly off of the app root
  #      spec: true
  #
  #    development:
  #      test: true
  #      spec: false
  #
  # The default configuration is to add test and spec directories to the autoload_path.  You can easily prevent any of them by setting
  # the boolean value to false.  You can add additional directories by adding the directory name and true.
  #
  # Load order:
  # The default config for test and development is to add the test and spec directories if they exist.  The config file ~/.ducktestrc
  # in the home directory is loaded and merged with the default config and will override it's values.  Next, the config file .ducktest in the app
  # directory is loaded and merged with the default config and will override it's values.  So, the rule is simple.
  # - home directory overrides default
  # - app directory overrides both
  class AutoloadConfig
    include LoggerHelper
  
    attr_accessor :paths

    ##################################################################################
    # Do I really have to say it?
    def initialize
      super
      self.paths = []
      self.load_config
    end

    ##################################################################################
    # Loads config settings for autoload paths
    def load_config
      config = {test: {test: true, spec: true}, development: {test: false, spec: false}}

      if File.exists?("~/.ducktestrc")
        config = merge(config, YAML.load_file("~/.ducktestrc"))
      end

      if File.exists?("#{Rails.root}/.ducktest")
        config = merge(config, YAML.load_file("#{Rails.root}/.ducktest"))
      end

      config.each do |item|
        if Rails.env.eql?(item.first.to_s)
          item.last.each do |path|
            if path.last
              file_spec = "#{Rails.root}/#{path.first}"
              if File.exist?(file_spec)
                self.paths.push(file_spec)
                ducklog.system "Adding path to autoload_paths: #{file_spec}"
              end
            end
          end
          break
        end
      end

    end

    ##################################################################################
    # Loads config settings for autoload paths
    def merge(config, buffer)
      buffer = buffer.symbolize_keys
      config.each do |item|
        if item.last.kind_of?(Hash)
          if buffer[item.first]
            item.last.merge!(buffer[item.first].symbolize_keys)
          end
        end
      end
      return config
    end

  end

end
