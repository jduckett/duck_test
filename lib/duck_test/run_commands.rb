module DuckTest

  # Run Commands provides support for linux style .rc config files to load and set environment, etc.
  class RunCommands

    include LoggerHelper

    ##################################################################################
    # Loads environment settings from the home directory of the user.
    def self.load

      file_spec = File.expand_path("~/.ducktestrc")
      if File.exist?(file_spec)
        Logger.ducklog.console "Loading environment from: #{file_spec}"
        self.config = YAML.load_file(file_spec)
        self.config = self.config.inject({}){|object,(k,v)| object[k.to_sym] = v; object}
      end
    end

    ##################################################################################
    # Saves the current environment settings to the home directory of the user.
    def self.save
      file_spec = File.expand_path("~/.ducktestrc")
      File.open(file_spec, "w") do |file|
        file.write(YAML.dump(self.config))
      end
    
    end

    ##################################################################################
    def self.config
      unless defined?(@@config)
        @@config = {}
      end
      return @@config
    end

    def self.config=(value)
      @@config = value
    end

  end
end

