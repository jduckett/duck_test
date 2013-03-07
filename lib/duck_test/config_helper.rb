module DuckTest

  # For inclusion in classes that need the standard attributes
  module ConfigHelper

    ##################################################################################
    # Root directory for all files to watch.  Typically, this will equate to Rails.root
    # The default value is the current directory '.'
    #
    #     puts DuckTest::Config.root  # '.'
    #
    # @return [String]
    def root
      return @root ||= "."
    end

    ##################################################################################
    # Sets the root directory for all files to watch.  Typically, this will equate to Rails.root
    # The default value is the current directory '.', however, DuckTest::Config will set this value
    # to the Rails.root directory if being loaded in a Rails environment.  The purpose of this attribute
    # is to account for the event that a development environment might deviate slightly from the standard
    # to compensate for an unknown requirement.
    #
    #     DuckTest::Config.root = "/my_directory"
    #     puts DuckTest::Config.root  # => '/my_directory'
    #
    # @return [String]
    def root=(value)
      @root = value.to_s unless value.blank?
      @root = File.expand_path(@root) unless @root.blank?
      return @root
    end

    ##################################################################################
    # @note See {file:README.md#base_directories} for details and examples
    # The watch_basedir is used when evaluating directories and files and it's main purpose is to provide
    # the conveinence of not having to specify full directory paths in watch definitions.
    #
    # @return [String] Returns the current value of watch_basedir
    def watch_basedir
      return @watch_basedir ||= ""
    end

    ##################################################################################
    # Sets the current of watch_basedir.
    # @return [String]
    def watch_basedir=(value)
      @watch_basedir = value.to_s unless value.blank?
    end

    ##################################################################################
    # @note See {file:README.md#base_directories} for details and examples
    # The runnable_basedir is used when evaluating directories and files and it's main purpose is to provide
    # the conveinence of not having to specify full directory paths in runnable definitions.
    #
    # @return [String] Returns the current value of runnable_basedir
    def runnable_basedir
      return @runnable_basedir ||= ""
    end

    ##################################################################################
    # Sets the current of runnable_basedir.
    # @return [String]
    def runnable_basedir=(value)
      @runnable_basedir = value.to_s unless value.blank?
    end

    ##################################################################################
    # Controls if tests/specs should be run automatically when changed.
    # @return [Boolean]
    def autorun
      @autorun = true unless defined? @autorun
      @autorun
    end

    ##################################################################################
    # Returns true is autorun is enabled, otherwise, returns false.
    # @return [Boolean]
    def autorun?
      @autorun
    end

    ##################################################################################
    # Sets if tests/specs should be run automatically when changed.  A value of true
    # means test will be automatically run, otherwise, tests have to be run manually.
    # @return [Boolean]
    def autorun=(value)
      @autorun = value
    end

    ##################################################################################
    # Constructs a message indicating the current status of autorun.
    # @return [String] Current autorun status message.
    def autorun_status
      return "Autorun is #{self.autorun ? 'ON' : 'OFF'}"
    end

  end
end
