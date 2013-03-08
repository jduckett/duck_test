module DuckTest

  # Console commands
  class Commands

    include LoggerHelper
    include Usage

    ##################################################################################
    def initialize
      super
    end

    ##################################################################################
    def help
      return self.to_s
    end

    ##################################################################################
    # Displays standard usage details
    def to_s
      usage(:usage, true)
      return nil
    end

    ##################################################################################
    # See {Logger.log_level}
    # @return [String] The output message
    def ar(value = nil)
      if value.blank?
        usage(:ar, true)
        msg = "Current log level: #{Logger.to_severity(ActiveRecord::Base.logger.level)}"
      else
        # converts from a symbol to a number
        ActiveRecord::Base.logger.level = Logger.to_severity(value)
        msg = "Log level set to: #{value}"
      end
      return msg
    end

    ##################################################################################
    # Toggles autorun on/off.
    # @return [String] The output message
    def autorun
      return DuckTest::Config.framework.toggle_autorun
    end

    ##################################################################################
    # Lists all of the files that have been blacklisted.
    # @return [String] The output message
    def blacklist
      list = []
      DuckTest::Config.framework.black_list.each {|item| list.push(item.first)}
      list.sort.each {|item| ducklog.console item}
      return ""
    end

    ##################################################################################
    # Lists all of the non-runnable and runnable files that have been loaded into memory during the current session.
    # @return [String] The output message
    def history
      framework = DuckTest::Config.framework

      ducklog.console "================================="

      if framework.non_loadable_history.length > 0 || framework.non_runnable_history.length > 0 || framework.runnable_history.length > 0

        ducklog.console "\r\n  Non-loadable file(s)" if framework.non_loadable_history.length > 0

        framework.non_loadable_history.each do |file_spec|
          ducklog.console "      #{file_spec.gsub("#{framework.root}#{File::SEPARATOR}", "")}"
        end

        ducklog.console "\r\n  Non-runnable file(s)" if framework.non_runnable_history.length > 0

        framework.non_runnable_history.each do |file_spec|
          ducklog.console "      #{file_spec.gsub("#{framework.root}#{File::SEPARATOR}", "")}"
        end

        ducklog.console "\r\n  Runnable file(s)" if framework.runnable_history.length > 0

        framework.runnable_history.each do |file_spec|
          ducklog.console "      #{file_spec.gsub("#{framework.root}#{File::SEPARATOR}", "")}"
        end

      else
        ducklog.console "  Zero files have been changed and run"
      end

      return ""
    end

    ##################################################################################
    # Displays information about the current loaded testing framework.
    # @return [String] The output message
    def info
      puts DuckTest::Config.framework.info
      return ""
    end

    ##################################################################################
    # See {FrameWork::Queue#latency}
    # @return [String] The output message
    def latency(value = nil)
      unless usage(:latency, value.blank?)
        DuckTest::Config.framework.set_latency(value.to_f)
        msg = "Queue latency set to: #{value}"
      end
      return msg
    end

    ##################################################################################
    # See {Platforms::Listener#speed}
    # @return [String] The output message
    def listen_speed(value = nil)
      msg = nil
      unless usage(:listen_speed, value.blank?)
        DuckTest::Config.framework.set_listener_speed(value.to_f)
        msg = "Listener speed set to: #{value}"
      end
      return msg
    end

    ##################################################################################
    # See {Logger.log_level}
    # @return [String] The output message
    def ll(value = nil)
      if value.blank?
        usage(:ll, true)
        msg = "Current log level: #{Logger.to_severity(Logger.log_level)}"
      else
        Logger.log_level = value
        msg = "Log level set to: #{value}"
      end
      return msg
    end

    ##################################################################################
    # Lists mappings of non-runnable to runnable files.
    # @return [String] The output message
    def maps
      framework = DuckTest::Config.framework

      framework.watch_configs.each do |watch_config|
        ducklog.console "================================="
        ducklog.console "     pattern: #{watch_config.pattern}"
        ducklog.console "  runnrable?: #{watch_config.runnable?}"
        ducklog.console "       maps?: #{watch_config.maps.length > 0 ? true : false}"
        ducklog.console ""

        if watch_config.maps.length > 0
          framework.white_list.each do |file_object|
            if file_object.last[:watch_config].eql?(watch_config)
              unless file_object.last[:is_dir]
                runnable_files = framework.find_runnable_files(file_object.first, file_object.last[:watch_config])
                if runnable_files.length > 0
                  ducklog.console "        #{file_object.first.gsub("#{framework.root}#{File::SEPARATOR}", "")}"
                  runnable_files.each do |file_spec|
                    ducklog.console "            executes ==> #{file_spec.gsub("#{framework.root}#{File::SEPARATOR}", "")}"
                  end
                end
              end
            end
          end
        end

      end

      return ""
    end

    ##################################################################################
    # Runs all tests that have been automagically loaded via the queue as a result of a file change or
    # loaded manually with the load command.
    # @return [String] The output message
    def run(value=nil)
      unless usage(:run, value.kind_of?(Symbol) && value.eql?(:help))
        return DuckTest::Config.framework.run_manually(value)
      end
    end

    ##################################################################################
    # Loads all runnable test files from disk and executes the run_tests method.
    # @return [String] The output message
    def runall
      return DuckTest::Config.framework.run_all
    end

    ##################################################################################
    # Saves the current environment settings to the users home directory  ~/.ducktestrc
    def save
      RunCommands.config[:latency] = DuckTest::Config.framework.queue.latency
      RunCommands.config[:speed] = DuckTest::Config.framework.queue.speed
      RunCommands.config[:listener_speed] = DuckTest::Config.framework.listener.speed
      RunCommands.config[:ar] = Logger.to_severity(ActiveRecord::Base.logger.level)
      RunCommands.config[:ll] = Logger.to_severity(Logger.log_level)
      RunCommands.save
      return ""
    end

    ##################################################################################
    # See {FrameWork::Queue#speed}
    # @return [String] The output message
    def speed(value = nil)
      msg = nil
      unless usage(:speed, value.blank?)
        DuckTest::Config.framework.set_queue_speed(value.to_f)
        msg = "Queue speed set to: #{value}"
      end
      return msg
    end

    ##################################################################################
    # Lists all of the files that have been whitelisted.
    # @return [String] The output message
    def whitelist
      list = []
      DuckTest::Config.framework.white_list.each {|item| list.push(item.first)}
      list.sort.each {|item| ducklog.console item}
      return ""
    end

  end
end

