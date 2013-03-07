module DuckTest

  # Data and methods to define and configure runnable watch lists, frameworks, everything to control the behavior of DuckTest.
  class Config
    include LoggerHelper

    ##################################################################################
    def initialize

      super

      #Logger.log_level = :debug

      #self.class.reset

      if defined?(Rails)
        root Rails.root
      end

    end

    ##################################################################################
    # This is a boolean flag used to determine if at least one config block has been run during start up.
    # If a block has not been run, then, DuckTest will attempt to autoload a default configuration for the current target testing
    # framework.
    # @return [TrueClass, FalseClass] A boolean indicating if at least one config block has been run.
    def self.block_run
      @@block_run = false unless defined?(@@block_run)
      return @@block_run
    end

    def self.block_run?
      return self.block_run
    end

    def self.block_run=(value)
      @@block_run = value
    end

    ##################################################################################
    # Returns the current configuration Hash containing attributes for paths, testing frameworks, etc.
    # @return [Hash]
    def self.config
      reset unless defined?(@@config)
      return @@config
    end

    ##################################################################################
    # Sets default values for all configuration attributes and adds a default testing framework.
    # @return [Hash] The current configuration Hash.
    def self.reset
      @@config = {default_framework: :testunit}

      # defaults for a testing framework are set by get_framework if it does not already exist
      # make a call to set the defaults
      self.get_framework(:testunit)

      return @@config
    end

    ##################################################################################
    # Sets and returns the value of {.default_framework}.
    #
    #   DuckTest.config do
    #
    #     # will load :rspec framework by default
    #     default_framework :rspec
    #
    #   end
    #
    # @return [Symbol] Current value of {.default_framework}
    def default_framework(value = nil)
      self.class.default_framework = value
      return self.class.default_framework
    end

    ##################################################################################
    # Gets the current value of :default_framework
    # @return [Symbol] Current value of :default_framework
    def self.default_framework
      return self.config[:default_framework]
    end

    ##################################################################################
    # Sets the default testing framework to load when the Rails console starts.
    # @return [Symbol] Current value of :default_framework
    def self.default_framework=(value)
      self.config[:default_framework] = value.to_sym unless value.blank?
      return self.config[:default_framework]
    end

    ##################################################################################
    # Returns the instance of the testing framework that is currently loaded.
    # @return [DuckTest::FrameWork::Base]
    def self.framework
      @@framework = nil unless defined?(@@framework)
      return @@framework
    end

    ##################################################################################
    # Conveinence method to return the name of the current testing framework.  This is used
    # throughout the code base in debugging statements.
    # @return [String]
    def self.framework_name
      return self.framework.blank? ? "not set yet" : self.framework.name
    end

    ##################################################################################
    # Reloads the current target framework.
    # @return [NilClass]
    def self.reload!
      if defined?(@@framework) && !@@framework.blank?
        # this should be changed to debug later
        ducklog.console "framework already loaded.  shutting it down... #{@@framework.blank?}"
        remove_class_variable(:@@framework)
      end

      unless ENV["DUCK_TEST"].blank?
        self.default_framework = ENV["DUCK_TEST"]
      end

      target = self.default_framework

      DuckTest::DefaultConfig.config(target) unless self.block_run?

      case target
      when :testunit
        @@framework = DuckTest::FrameWork::TestUnit::FrameWork.new(target).startup(self.get_framework(target))

      when :rspec
        @@framework = DuckTest::FrameWork::RSpec::FrameWork.new(target).startup(self.get_framework(target))

      end

      return nil
    end

    ##################################################################################
    # Sets the root directory for all test/spec files to watch.  Typically, this will equate to Rails.root
    #
    #    # sets the root directory
    #    DuckTest.config do
    #      root "/my_root"
    #    end
    #
    #    puts DuckTest::Config.root  # => "/my_root"
    #
    # @return [NilClass]
    def root(value)
      self.get_framework(self.current_framework)[:root] = value.to_s unless value.blank?
      return nil
    end

    ##################################################################################
    # Sets if tests/specs should be run automatically when changed.
    #
    #    # shuts autorun off
    #    DuckTest.config do
    #      autorun false
    #    end
    # @param [Boolean] value (Default: true) A value of true means test will be automatically run, otherwise, tests have to be run manually.
    # @return [NilClass]
    def autorun(value)
      self.get_framework(self.current_framework)[:autorun] = value
      return nil
    end

    ##################################################################################
    # @note See {Config#watch_basedir Config#watch_basedir} for an explanation of base directories.
    # Sets the base directory for all runnable test files.
    # @param [String, Symbol] value A valid directory path.
    # @return [NilClass]
    def runnable_basedir(value)
      unless value.blank?
        self.get_framework(self.current_framework)[:runnable_basedir] = value.to_s
      end
      return nil
    end

    ##################################################################################
    # Sets the base directory for all non-runnable (watched) files.  Base directories are provided as a conveinence
    # to help keep configuration files from becoming cluttered.  Basically, removes the need to include directory
    # names when defining runnable and watch configurations.
    #
    #    # without base directories
    #    DuckTest.config do
    #      watch "app/**/*" do
    #        map sub_directory: /^app/models/, file_name: /[a-z]/ do
    #          map sub_directory: /^test\/unit/, file_name: /[a-z]/
    #          map sub_directory: /^test\/functional/, file_name: /[a-z]/
    #        end
    #      end
    #    end
    #
    #    # with base directories
    #    DuckTest.config do
    #
    #      runnable_basedir :test
    #      watch_basedir :app
    #
    #      watch "**/*" do
    #        map sub_directory: /^models/, file_name: /[a-z]/ do
    #          map sub_directory: /^unit/, file_name: /[a-z]/
    #          map sub_directory: /^functional/, file_name: /[a-z]/
    #        end
    #      end
    #    end
    #
    # @param [String, Symbol] value A valid directory path.
    # @return [NilClass]
    def watch_basedir(value)
      unless value.blank?
        self.get_framework(self.current_framework)[:watch_basedir] = value.to_s
      end
      return nil
    end

    ##################################################################################
    # Sets the excluded filter.
    # @param [Regexp] value A valid Regexp as per {FrameWork::FilterSet#excluded}
    # @return [NilClass]
    def excluded(value = nil)
      if self.current_watch_config
        self.current_watch_config.filter_set.excluded =  value
      else
        self.get_framework(self.current_framework)[:excluded] = value
      end
      return nil
    end

    ##################################################################################
    # Sets the excluded_dirs filter.
    # @param [Regexp] value A valid Regexp as per {FrameWork::FilterSet#excluded_dirs}
    # @return [NilClass]
    def excluded_dirs(value = nil)
      if self.current_watch_config
        self.current_watch_config.filter_set.excluded_dirs =  value
      else
        self.get_framework(self.current_framework)[:excluded_dirs] = value
      end
      return nil
    end

    ##################################################################################
    # Sets the included filter.
    # @param [Regexp] value A valid Regexp as per {FrameWork::FilterSet#included}
    # @return [NilClass]
    def included(value = nil)
      if self.current_watch_config
        self.current_watch_config.filter_set.included =  value
      else
        self.get_framework(self.current_framework)[:included] = value
      end
      return nil
    end

    ##################################################################################
    # Sets the included_dirs filter.
    # @param [Regexp] value A valid Regexp as per {FrameWork::FilterSet#included_dirs}
    # @return [NilClass]
    def included_dirs(value = nil)
      if self.current_watch_config
        self.current_watch_config.filter_set.included_dirs =  value
      else
        self.get_framework(self.current_framework)[:included_dirs] = value
      end
      return nil
    end

    ##################################################################################
    # Sets the non_loadable filter.
    # @param [Regexp] value A valid Regexp as per {FrameWork::FilterSet#non_loadable}
    # @return [NilClass]
    def non_loadable(value = nil)
      if self.current_watch_config
        self.current_watch_config.filter_set.non_loadable =  value
      else
        self.get_framework(self.current_framework)[:non_loadable] = value
      end
      return nil
    end

    ##################################################################################
    # Represents the current framework being configured.
    #
    #    DuckTest.config do
    #      puts current_framework  # => :testunit
    #    end
    #
    def current_framework
      @current_framework ||= self.default_framework
      return @current_framework
    end

    ##################################################################################
    # Sets the current framework to configure.  Value can be a String or Symbol, however, the value
    # will be converted to a Symbol when assigned.  Examples of valid values are: :testunit, :rpsec, :minitest
    #
    #    # sets the current framework to :rspec
    #    DuckTest.config do
    #      current_framework = :rspec
    #    end
    #
    # @return [Symbol]
    ##################################################################################
    def current_framework=(value)
      @current_framework ||= self.current_framework
      @current_framework = value.to_sym
      return @current_framework
    end

    ##################################################################################
    # ...
    def current_watch_config
      return @current_watch_config
    end

    ##################################################################################
    # ...
    def current_watch_config=(value)
      @current_watch_config = value
      return @current_watch_config
    end

    ##################################################################################
    # Returns a Hash representing the configuration for a framework.
    #
    # @return [Hash]
    def self.get_framework(key)
      self.config[key] = {root: ".", autorun: true, runnable_basedir: "test", watch_basedir: "app"} unless self.config[key].kind_of?(Hash)
      return self.config[key]
    end

    # ...
    def get_framework(key)
      unless self.class.config[key]
        test_unit_framework = self.class.config[:testunit]
        if test_unit_framework
          self.class.get_framework(key)[:autorun] = test_unit_framework[:autorun]
          self.class.get_framework(key)[:runnable_basedir] = test_unit_framework[:runnable_basedir]
          self.class.get_framework(key)[:watch_basedir] = test_unit_framework[:watch_basedir]
          self.class.get_framework(key)[:excluded] = test_unit_framework[:excluded]
          self.class.get_framework(key)[:excluded_dirs] = test_unit_framework[:excluded_dirs]
          self.class.get_framework(key)[:included] = test_unit_framework[:included]
          self.class.get_framework(key)[:included_dirs] = test_unit_framework[:included_dirs]
        end
      end
      return self.class.get_framework(key)
    end

    ##################################################################################
    # Configures a framework
    # @param [String, Symbol] key Key is the name of the framework to configure.  Key is converted to a Symbol regardless of what value is passed.
    # @param [Hash] options             Options hash.  No options implemented at this time.  However, the Hash is passed to the block when executed.
    # @return [NilClass]
    def framework(key, options = {}, &block)
      prev_value = self.current_framework

      self.current_framework = key

      config = {framework: self.current_framework}.merge(options)

      yield config if block_given?

      self.current_framework = prev_value

      return nil
    end

    ##################################################################################
    # Watches a set of directories / files based on a pattern.  You can include an options Hash containing combinations of Regexps, Strings, and Symbols
    # to filter which directories files are actually watched.  There are basically two types of file sets that are watched.
    # - <b>runnable</b> test files (Test::Unit, RSpec, etc.) are defined using {#runnable}, which is simply a wrapper for the {#watch} method.
    #   The intent is that you can define a set of runnable tests that will be automagically executed when they are changed and saved.
    # - <b>non-runnable</b> files are anything except a runnable file.  Typically, all of the files under the app directory of a Rails application.
    #   The intent is that you can define non-runnable that are watched and mapped to runnable files that are triggered when non-runnable files are changed and saved.
    #
    # Example
    #   # I'm showing how to set the default base directories for runnable and non-runnable files for clarity.
    #   # The default settings of :test and :app are set for you during initialization.
    #   DuckTest.config do
    #     runnable_basedir: :test
    #     watch_basedir: :app
    #
    #     runnable "**/*",      # watches all of the runnable files in the test directory of a Rails app.
    #     watch "**/*"          # watches all of the non-runnable application files in the app directory of a Rails app.
    #   end
    #
    #   # Same as above, however, includes a filter
    #   DuckTest.config do
    #     watch "**/*", [/^bike/, /^car/, /^truck/]
    #   end
    #
    # A good way to think of the {#runnable} and {#watch} methods is we are using the standard Dir.glob method to retrieve a file set from disk and
    # using Regexp, String, Symbols, and Arrays or any combinations of the three to filter the file set via includes and excludes.  This should
    # be more enough to satisfy any need.
    #
    # In an attempt to help configuration from looking cluttered, the watch method will attempt to be smart about grabbing arguments.
    # You can specify included filters outside of the options Hash.  Meaning, you do not have to specify included:
    #
    #   # both of the following are equivalent
    #   DuckTest.config do
    #     watch "**/*", /^books/                        # assumes the second argument is the included: filter
    #     watch "**/*", [/^books/, /^truck/]
    #
    #     watch "**/*", included: /^books/              # explicitly defines the included: filter
    #     watch "**/*", included: [/^books/, /^truck/]
    #   end
    #
    #   # all of the following are equivalent
    #   watch "**/*", /^trucks/
    #   watch "**/*", [/^trucks/]
    #   watch "**/*", included: /^trucks/
    #   watch "**/*", included: [/^trucks/]
    #   watch "**/*",[/^trucks/, /^cars/]
    #   watch "**/*", included: [/^trucks/, /^cars/]
    #
    #   # all of the following are equivalent
    #   watch "**/*", :all
    #   watch "**/*", included: :all
    #   watch "**/*", included: [:all]
    # 
    # The included and excluded filters follow all of the same rules as {FrameWork::FileManager#watchable?}.  It is possible to do some moderately complex filtering such as:
    # 
    #   watch "**/*", included: /bike/, excluded: /truck/, included_dirs: [/models/, /controllers/], excluded_dirs: /views/
    # 
    # Since pattern is compliant with {http://ruby-doc.org/core-1.9.3/Dir.html#method-c-glob} the following are valid.
    # 
    #   watch "models**/*"
    #
    #   watch ["models**/*", "controllers**/*"]
    #
    # @overload watch(pattern, included, options = {}, &block)
    #   @param [String] pattern    Pattern is compliant with {http://ruby-doc.org/core-1.9.3/Dir.html#method-c-glob}
    #   @param [String] included   
    #   @param [Hash] options      Options hash for watch list configurations.
    #                              - :included        See {FrameWork::FilterSet#included}
    #                              - :included_dirs   See {FrameWork::FilterSet#included_dirs}
    #                              - :excluded        See {FrameWork::FilterSet#excluded}
    #                              - :excluded_dirs   See {FrameWork::FilterSet#excluded_dirs}
    # @return [NilClass]
    def watch(*args, &block)

      # ya know, I couldn't make the @overload statement above work correctly, so, i rigged it.
      # arguments are processed in expected order: right to left.
      config = args.last.kind_of?(Hash) ? args.pop : {}
      config = {runnable: false, standard_map: true}.merge(config)

      # developer may specify included outside of the options Hash
      # 
      # here /^books/ is considered the included filter
      # watch "my_files*", /^books/, excluded: /bikes/
      # 
      # here [/^books/, /^trucks/] is considered the included filter
      # watch "my_files*", [/^books/, /^trucks/], excluded_dirs: /unit/
      #
      use_arg_as_included = false
      if (args.last.kind_of?(Symbol) && args.last.eql?(:all)) || args.last.kind_of?(Regexp)
        use_arg_as_included = true

      elsif args.last.kind_of?(Array)
        args.last.each do |item|
          if item.kind_of?(Regexp) || (item.kind_of?(Symbol) && item.eql?(:all))
            use_arg_as_included = true
            break
          end
        end
      end

      if use_arg_as_included
        config[:included] = args.pop
      end

      pattern = args.last.kind_of?(String) || args.last.kind_of?(Array) ? args.pop : nil

      unless pattern.blank?
        config[:pattern] = pattern

        framework = self.get_framework(self.current_framework)
        config[:autorun] = config[:autorun].nil? ? framework[:autorun] : config[:autorun]
        config[:autorun] = false unless config[:runnable]

        config[:watch_basedir] = config[:basedir] unless config[:basedir].blank?
        config[:watch_basedir] = config[:watch_basedir].blank? ? framework[:watch_basedir] : config[:watch_basedir]
        config[:runnable_basedir] = config[:runnable_basedir].blank? ? framework[:runnable_basedir] : config[:runnable_basedir]
        buffer_config = {}
        buffer_config[:excluded] = framework[:excluded]
        buffer_config[:excluded_dirs] = framework[:excluded_dirs]
        buffer_config[:included] = framework[:included]
        buffer_config[:included_dirs] = framework[:included_dirs]
        config = buffer_config.merge(config)

        prev_value = self.current_watch_config

        self.current_watch_config = FrameWork::WatchConfig.new(config)

        yield self.current_watch_config if block_given?

        # i know it seems like a waste to grab this variable again, but, things may have changed
        # by the time we reach this point since we just executed a block, so, i'm grabbing it to be safe.
        framework = self.get_framework(self.current_framework)
        framework[:watch_configs] = [] unless framework[:watch_configs].kind_of?(Array)
        framework[:watch_configs].push(self.current_watch_config)

        self.current_watch_config = prev_value

        return nil
      end

    end

    ##################################################################################
    # A wrapper function for {DuckTest::Config#watch DuckTest::Config#watch}.  The only difference
    # is that {FrameWork::WatchConfig#runnable} is forced set to true and the :watch_basedir is
    # set to match the current framework :runnable_basedir.  That way all of the filter sets and mappings
    # will work as expected.
    # @return [NilClass]
    def runnable(*args, &block)
      args.push({}) unless args.last.kind_of?(Hash)
      args.last[:runnable] = true

      unless args.last[:basedir].blank?
        args.last[:runnable_basedir] = args.last[:basedir]
      end

      if args.last[:watch_basedir].blank?
        if args.last[:runnable_basedir].blank?
          args.last[:watch_basedir] = self.get_framework(self.current_framework)[:runnable_basedir]
        else
          args.last[:watch_basedir] = args.last[:runnable_basedir]
        end
      end
      watch(*args, &block)
    end

    ##################################################################################
    # Create a map between non-runnable and runnable tests.
    # {include:file:MAPS.md}
    def map(sub_directory = nil, file_name = nil, options = {}, &block)
      config = {}
      config[:watch_basedir] = self.current_watch_config.watch_basedir unless self.current_watch_config.watch_basedir.blank?
      config[:runnable_basedir] = self.current_watch_config.runnable_basedir unless self.current_watch_config.runnable_basedir.blank?
      config.merge!(options)
      map = DuckTest::FrameWork::Map.new(sub_directory, file_name, config, &block)
      self.current_watch_config.maps.push(map) if map.valid?
      return map
    end

    ##################################################################################
    # Creates standard mappings between non-runnable and runnable tests for the current framework.
    def standard_maps

      case self.current_framework
      when :testunit
        map /^controllers/ do
          target /^unit/ do
            file_name do |value, cargo|
              buffer = File.basename(cargo, ".rb").gsub("s_controller", "")
              value =~ /#{buffer}_test.rb/ ? true : false
            end
          end
          target /^functional/ do
            file_name do |value, cargo|
              buffer = File.basename(cargo, ".rb").gsub("_controller", "")
              value =~ /#{buffer}_controller_test.rb/ ? true : false
            end
          end
        end
        map /^models/ do
          target /^unit/ do
            file_name do |value, cargo|
              value =~ /#{File.basename(cargo, ".rb")}_test.rb/ ? true : false
            end
          end
          target /^functional/ do
            file_name do |value, cargo|
              value =~ /#{File.basename(cargo, ".rb")}s_controller_test.rb/ ? true : false
            end
          end
        end

      when :rspec
        map /^controllers/ do
          target /^models/ do
            file_name do |value, cargo|
              buffer = File.basename(cargo, ".rb").gsub("s_controller", "")
              value =~ /#{buffer}_spec.rb/ ? true : false
            end
          end
          target /^controllers/ do
            file_name do |value, cargo|
              buffer = File.basename(cargo, ".rb").gsub("_controller", "")
              value =~ /#{buffer}_controller_spec.rb/ ? true : false
            end
          end
        end
        map /^models/ do
          target /^models/ do
            file_name do |value, cargo|
              value =~ /#{File.basename(cargo, ".rb")}_spec.rb/ ? true : false
            end
          end
          target /^controllers/ do
            file_name do |value, cargo|
              value =~ /#{File.basename(cargo, ".rb")}s_controller_spec.rb/ ? true : false
            end
          end
        end
      end

    end

    ##################################################################################
    # Sets the log level for the ducklog.
    # @return [NilClass]
    def log_level(value)
      Logger.log_level = value
      return nil
    end

    ##################################################################################
    # Sets a block to run prior to loading any test files that have changed and are in the queue.
    # @return [NilClass]
    def pre_load(&block)
      if block_given?
        self.get_framework(self.current_framework)[:pre_load] = block
      end
      return nil
    end

    ##################################################################################
    # Sets a block to run prior to running any test files that have changed and are in the queue.
    # @return [NilClass]
    def pre_run(&block)
      if block_given?
        self.get_framework(self.current_framework)[:pre_run] = block
      end
      return nil
    end

    ##################################################################################
    # Sets a block to run prior to loading any test files that have changed and are in the queue.
    # @return [NilClass]
    def post_load(&block)
      if block_given?
        self.get_framework(self.current_framework)[:post_load] = block
      end
      return nil
    end

    ##################################################################################
    # Sets a block to run prior to running any test files that have changed and are in the queue.
    # @return [NilClass]
    def post_run(&block)
      if block_given?
        self.get_framework(self.current_framework)[:post_run] = block
      end
      return nil
    end

  end
end























