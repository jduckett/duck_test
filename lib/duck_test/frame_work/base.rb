require 'thor/shell/basic'

module DuckTest
  module FrameWork

    autoload :FileManager, 'duck_test/frame_work/file_manager'
    autoload :FilterSet, 'duck_test/frame_work/filter_set'
    autoload :Map, 'duck_test/frame_work/map'
    autoload :Queue, 'duck_test/frame_work/queue'
    autoload :QueueEvent, 'duck_test/frame_work/queue_event'
    autoload :RSpec, 'duck_test/frame_work/rspec/base'
    autoload :Runner, 'duck_test/frame_work/runner'
    autoload :TestUnit, 'duck_test/frame_work/test_unit/base'
    autoload :WatchConfig, 'duck_test/frame_work/watch_config'
    autoload :WatchEvent, 'duck_test/frame_work/watch_event'

    ##################################################################################
    # Base class for all FrameWork implementations testunit, minitest, rpsec, etc.
    class Base
      include DuckTest::ConfigHelper
      include FileManager
      include LoggerHelper
      #include Thor::Actions

      attr_accessor :name
      attr_accessor :listener
      attr_accessor :queue
      attr_accessor :pre_load
      attr_accessor :pre_run
      attr_accessor :post_load
      attr_accessor :post_run

      ##################################################################################
      # Initializes a testing framework object.
      # @param [String, Symbol] name The name of the testing framwork: :testunit, :rspec, etc.
      # @return [Base] Instance of {Base}
      def initialize(name)
        super()
        self.name = name
      end

      ##################################################################################
      # Clears all of the currently queue test suites.  The intention is to allow a developer to override this method
      # within a custom framework class to modify the behavior without having to alter {Base}
      def clear_tests
        ::Test::Unit::TestCase.reset
      end

      ##################################################################################
      # Displays information about the current loaded testing framework.
      # @return [String] The output message
      def info
        pad = 25
        stats_black = self.list_stats(:black)
        stats_white = self.list_stats(:white)

        buffer = %(\r\n#{"DuckTest version:".rjust(pad)} #{DuckTest::VERSION})
        buffer << %(\r\n#{"Ruby:".rjust(pad)} #{RUBY_VERSION})
        buffer << %(\r\n#{"Rails:".rjust(pad)} #{Rails.version})
        buffer << %(\r\n#{"Gem:".rjust(pad)} #{Gem::VERSION})
        buffer << %(\r\n#{"Testing framework:".rjust(pad)} #{self.name})
        buffer << %(\r\n#{"Autorun:".rjust(pad)} #{self.autorun ? "ON" : "OFF"})
        buffer << %(\r\n#{"Blacklisted:".rjust(pad)} Directories: (#{stats_black[:dirs]})  Files: (#{stats_black[:files]}))
        buffer << %(\r\n#{"Whitelisted:".rjust(pad)} Directories: (#{stats_white[:dirs]})  Files: (#{stats_white[:files]}))
        buffer << %(\r\n#{"Listener Speed:".rjust(pad)} #{self.listener.speed})
        buffer << %(\r\n#{"ActiveRecord Log Level:".rjust(pad)} #{DuckTest::Logger.to_severity(ActiveRecord::Base.logger.level)})
        buffer << %(\r\n#{"Log Level:".rjust(pad)} #{DuckTest::Logger.to_severity(DuckTest::Logger.ducklog.level)})
        buffer << %(\r\n#{"Queue Latency:".rjust(pad)} #{self.queue.latency})
        buffer << %(\r\n#{"Queue Speed:".rjust(pad)} #{self.queue.speed})

        return buffer
      end

      ##################################################################################
      # ...
      def listener_event(event)
        # TODO add support for all of the events.

        ducklog.system "listener_event: #{event.flag}"

        begin
          case event.flag
          when :destroy
          when :update
            self.queue.push(event.file_spec)

          when :create
            file_object_parent = self.find_file_object_parent(:white, event.file_spec)
            if file_object_parent
              if self.watch_file_spec(event.file_spec, file_object_parent[:watch_config])
                self.queue.push(event.file_spec)
              else
                self.add_to_list(:black, event.file_spec, file_object_parent[:watch_config])
              end
            else
              self.add_to_list(:black, event.file_spec, file_object_parent[:watch_config])
            end

          when :moved
            #self.queue.push(event.file_spec)

          end

        rescue Exception => e
          ducklog.exception e
        end

      end

      ##################################################################################
      # Physically loads files from disk.
      def load_files_from_disk(event)

        ducklog.console "load_files_from_disk: #{event.files.length}"

        event.files.each do |file|

          begin

            ducklog.console "==> #{File.basename(file)}"
            load file

          rescue Exception => e
            ducklog.exception e
          end

        end

      end

      ##################################################################################
      # Global flag used to prevent Test::Unit::Runner from running automatically after exiting the console
      # @return [Boolean]
      def self.ok_to_run
        @@ok_to_run = false unless defined?(@@ok_to_run)
        return @@ok_to_run
      end

      def self.ok_to_run=(value)
        @@ok_to_run = value
      end

      ##################################################################################
      # Processes a list of file specifications and prepares them to be run
      def queue_event(event)

        non_runnable_files = []
        runnable_files = []

        begin

          if self.autorun?

            ducklog.console "\r\n==> preparing tests: #{event.files.length}"

            event.files.each do |file_spec|

              ducklog.system "\r\n  ==> file_spec: #{file_spec}"

              # is the file black listed?
              if self.black_listed?(file_spec)
                ducklog.system "    black_listed? true"

              else

                file_object = self.white_listed?(file_spec)
                ducklog.system "    white_listed? #{!file_object.blank?}"

                # is the file white listed and runnable?
                if file_object && file_object[:watch_config].runnable?
                  if file_object[:is_dir]
                    ducklog.system "    --> SHOULD HAVE RUN THE FILE, BUT, IT IS A DIRECTORY !!!! white_listed? true   runnable? #{file_object[:watch_config].runnable?} is_dir: #{file_object[:is_dir]}"
                  else
                    ducklog.system "    --> SHOULD RUN THE FILE !!!! white_listed? true   runnable? #{file_object[:watch_config].runnable?} is_dir: #{file_object[:is_dir]}"
                    runnable_files.push(file_spec)
                  end

                # is the file white listed and NON-runnable?
                elsif file_object && !file_object[:watch_config].runnable?

                  ducklog.system "    --> Need to resolve if file is associated with runnable files"
                  non_runnable_files.push(file_spec)
                  runnable_files.concat(find_runnable_files(file_spec, file_object[:watch_config]))

                else

                  if self.white_listed?(file_spec)
                    ducklog.system "i don't know what to do"

                  else

                    # if we have a file that has changed and was not previously on the whitelist, then, the event must have been triggered due to some
                    # other action such as after being created or being moved to the containing directory.
                    file_object_parent = self.find_file_object_parent(:white, file_spec)

                    # is the file watchable?
                    if file_object_parent && self.watchable?(file_spec, file_object_parent[:watch_config])
                      ducklog.system "      YES - file_object_parent true AND watchable  - the file should be whitelisted"
                      ducklog.system "        need to resolve if file is associated with runnable files"
                      non_runnable_files.push(file_spec)
                      runnable_files.concat(find_runnable_files(file_spec, file_object_parent[:watch_config]))
                    else
                      ducklog.system "      NO - file_object_parent false - the file should be blacklisted"
                    end

                  end
                end
              end

            end

            ducklog.console "  ==> running tests: #{runnable_files.length}"

            run_fork(non_runnable_files, runnable_files, true)

          else

            ducklog.console self.autorun_status
            self.queue.reset

          end

        rescue Exception => e
          ducklog.exception e
        end

        return runnable_files
      end

      ##################################################################################
      # Loads all runnable test files from disk and executes the run_tests method.
      # @return [String] A message indicating the status of the run.
      def run_all
        msg = nil

        non_runnable_files = []
        runnable_files = []

        self.white_list.each do |file_object|
          unless file_object.last[:is_dir]
            if file_object.last[:watch_config].runnable?
              runnable_files.push(file_object.first)
            else
              non_runnable_files.push(file_object.first)
            end
          end
        end

        run_fork(non_runnable_files, runnable_files, true)

        return msg
      end

      ##################################################################################
      def loadable?(file_spec)
        value = false

        file_object = self.white_listed?(file_spec)
        if file_object
           value = !file_object[:watch_config].filter_set.non_loadable?(file_spec, nil)
        end

        return value
      end

      ##################################################################################
      # Loads all of the runnable tests contained in the runnable_files argument and executes the run_tests method.
      # @param [Array] non_runnable_files       A array of non-runnable files to load.
      # @param [Array] runnable_files           A array of runnable files load and execute.
      # @param [Boolean] force_run              Forces the tests to run regardless of the current state of autorun.
      # @return [NilClass]
      def run_fork(non_runnable_files, runnable_files, force_run = false)

        buffer = []
        non_runnable_files.each do |file_spec|
          if self.loadable?(file_spec)
            buffer.push(file_spec)
          else
            self.non_loadable_history = self.non_loadable_history.concat([file_spec])
          end
        end

        self.non_runnable_history = self.non_runnable_history.concat(buffer)
        non_runnable_files = self.non_runnable_history

        self.runnable_history = self.runnable_history.concat(runnable_files)

        ducklog.console self.autorun_status

        if runnable_files.length > 0

          pid = fork do

            if non_runnable_files.length > 0

              clear_constants(non_runnable_files)

              self.pre_load.call self, :non_runnable unless self.pre_load.blank?

              load_files_from_disk(QueueEvent.new(self, non_runnable_files))

              self.post_load.call self, :non_runnable unless self.post_load.blank?

            end

            self.pre_load.call self, :runnable unless self.pre_load.blank?

            clear_tests

            load_files_from_disk(QueueEvent.new(self, runnable_files))

            self.post_load.call self, :runnable unless self.post_load.blank?

            if self.autorun || force_run

              self.pre_run.call self unless self.pre_run.blank?

              self.class.ok_to_run = true

              run_tests

              # prevents tests from autorunning when the console exits.
              self.class.ok_to_run = false

              self.post_run.call self unless self.post_run.blank?

            end

          end

          Process.wait pid

        end
        
        if defined?(ActiveRecord::Base)
          ::ActiveRecord::Base.clear_active_connections!
          ::ActiveRecord::Base.establish_connection
        end

      end

      ##################################################################################
      # Manually runs any tests pending in the queue.
      # @return [String] A message indicating the status of the run.
      def run_manually(expressions = nil)
        msg = nil
        list = []
        expressions = expressions.kind_of?(Symbol) ? expressions.to_s : expressions
        if expressions.kind_of?(String)
          if expressions.include?(",")
            expressions = expressions.split(",")

          elsif expressions.include?(" ")
            expressions = expressions.split(" ")

          else
            expressions = [expressions]

          end
        end
        expressions = expressions.kind_of?(Regexp) ? [expressions] : expressions
        expressions = expressions.kind_of?(Array) ? expressions : [expressions]

        self.queue.reset
        
        self.white_list.each do |file_object|

          if !file_object.last[:is_dir] && file_object.last[:watch_config].runnable?

            file_spec = file_object.first
            file_name = File.basename(file_spec, ".rb")

            expressions.each do |expression|

              expression = expression.kind_of?(Symbol) ? expression.to_s : expression

              if expression.kind_of?(String)

                if file_name =~ /^#{expression}/
                  list.push(file_spec)
                end

              elsif expression.kind_of?(Regexp)

                if file_name =~ expression
                  list.push(file_spec)
                end

              end

            end
          end

        end

        if list.length > 1
          list.each_with_index {|item, index| STDOUT.puts "#{(index + 1).to_s.rjust(3)} - #{item.gsub(self.root, "")}"}
          action = Thor::Shell::Basic.new.ask("Which file would you like to run (ENTER for all) ?")
          unless action.blank?
            buffer = []
            index = action.to_i - 1
            if (index >= 0 && index < list.length)
              buffer.push(list[index])
              list = buffer
            else
              list = []
            end
            
          end
        end
        
        if list.length > 0
          self.run_fork([], list, true)
        end

        return msg
      end

      ##################################################################################
      # See {Platforms::Listener#speed}
      # @return [NilClass]
      def set_listener_speed(value)
        begin
          self.listener.speed = value.to_f
        rescue
        end
        return nil
      end

      ##################################################################################
      # See {Queue#speed}
      # @return [NilClass]
      def set_queue_speed(value)
        begin
          self.queue.set_speed(value.to_f)
        rescue
        end
        return nil
      end

      ##################################################################################
      # See {Queue#latency}
      # @return [NilClass]
      def set_latency(value)
        begin
          self.queue.set_latency(value.to_f)
        rescue
        end
        return nil
      end

      ##################################################################################
      # Configures and starts a testing framework.
      # @param [Hash] config  Hash containing all configuration values for the framework: paths, autorun, watch configurations, etc.
      # @return [Base] Returns self.
      def startup(config)

        begin

          ducklog.system "Starting framework: #{self.name}"

          self.root = config[:root]
          self.autorun = config[:autorun]

          self.pre_load = config[:pre_load]
          self.pre_run = config[:pre_run]
          self.post_load = config[:post_load]
          self.post_run = config[:post_run]

          ducklog.console self.autorun_status

          unless config[:watch_configs].blank?
            config[:watch_configs].each do |watch_config|
              self.watch_configs.push(watch_config)
            end
          end

          self.build_watch_lists

          self.start

          RunCommands.load

          self.set_latency(RunCommands.config[:latency]) unless RunCommands.config[:latency].blank?
          self.set_listen_speed(RunCommands.config[:listen_speed]) unless RunCommands.config[:listen_speed].blank?
          self.set_queue_speed(RunCommands.config[:speed]) unless RunCommands.config[:speed].blank?

          unless RunCommands.config[:ar].blank?
            ActiveRecord::Base.logger.level = Logger.to_severity(RunCommands.config[:ar].to_sym)
          end

          unless RunCommands.config[:ll].blank?
            Logger.log_level = RunCommands.config[:ll]
          end

        rescue Exception => e
          ducklog.exception e
        end

        return self
      end

      ##################################################################################
      # TODO implement a shutdown.  future version might implement the ability to shutdown a framework
      # and switch to another on the fly.  at this point, i haven't even tried any test code to verify each of the native
      # notifiers will fully stop watching files.  I would not want to switch framework and have an orphan notifier trigger
      # an unwanted event.
      def shutdown
      end

      ##################################################################################
      # Starts a FileManager session.  start will instantiate a file watcher / listener for the current platform and begin watching
      # files based on configuration specified in config/environments.  Also, an event queue is created to listen for and act upon
      # changes to watched files.
      # @return [NilClass]
      def start
        self.queue = Queue.new
        self.queue.autorun = self.autorun
        self.queue.queue_event {|event| queue_event(event)}
        self.queue.start

        if self.is_linux? && self.available?
          self.listener = Platforms::Linux::Listener.new

        elsif self.is_mac? && self.available?
          self.listener = Platforms::Mac::Listener.new

        elsif self.is_windows? && self.available?
          self.listener = Platforms::Windows::Listener.new

        else
          self.listener = Platforms::Generic::Listener.new

        end

        unless self.listener.blank?

          self.listener.listener_event {|event| listener_event(event)}

          ducklog.console "Loading watchlist for: #{self.name}"
          ducklog.system "========================================================="

          self.white_list.each do |file|
            file_spec = file.first
            ducklog.system "watch: #{file_spec}"
            self.listener.watch(file_spec)
          end

          if self.white_list.length > 0
            stats = self.list_stats(:white)
            ducklog.console "Watching (#{stats[:dirs]}) directories (#{stats[:files]}) files..."
          else
            ducklog.console "You are not watching any files.  Add DuckTest.config block to config/environments/test.rb to watch files..."
          end

          self.listener.start
          
          ducklog.console "For help, type: 'duck' at the command prompt"

        end

        return nil
      end

      ##################################################################################
      # Stops the current instance of FileManager
      # @return [NilClass]
      def stop
        # need to stop the queue as well.
        self.queue.stop
        self.listener.stop
        return nil
      end

      ##################################################################################
      # Toggles the current state of autorun for the current FrameWork instance including it's queue.
      # @return [String] Returns a message indicating the current autorun status.
      def toggle_autorun
        self.autorun = self.autorun ? false : true
        self.queue.autorun = self.autorun
        return self.autorun_status
      end

      ##################################################################################
      # Returns the current total number of directories and files for the black or white list.
      # @return [Hash] Returns the stats for a list.
      def list_stats(target)
        stats = {dirs: 0, files: 0}
        list = target.eql?(:black) ? self.black_list : self.white_list
        
        if list.length > 0
          list.each do |file_object|
            if file_object.last[:is_dir]
              stats[:dirs] += 1
            else
              stats[:files] += 1
            end
          end
        end
        
        return stats
      end

      ##################################################################################
      # I'm pretty sure I will be able to deprecate this method since now I am running the tests
      # within a fork.  keeping it in case I need it later
      def clear_constants(file_list)

        #ActiveRecord::Base.s.verify_active_connections! if defined?(ActiveRecord::Base)

        file_list.each do |file_spec|

          begin

            file_name = File.basename(file_spec, ".*")
            ducklog.console "removing constant: #{file_name} ==> #{file_name.classify}"
            Object.send(:remove_const, file_name.classify.to_sym)

          rescue Exception => e
          # for now, I have decided not to warn the developer about constants that probably won't be there most of the time
          # ducklog.exception e
          end

        end

      end

    end
  end
end
