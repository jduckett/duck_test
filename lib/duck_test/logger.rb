module DuckTest

  # Conveinence methods providing access to the Logger class.
  module LoggerHelper

    # ...
    def ducklog
      return Logger.ducklog
    end

  end

  # Custom Logger
  class Logger < ::Logger #ActiveSupport::BufferedLogger

    SYSTEM = 6

    ##################################################################################
    # Instance of DuckTest::Logger
    def self.ducklog
      dir = defined?(Rails) ? Rails.root : "."
      return @@ducklog ||= self.new("#{dir}/log/ducktest.log", INFO)
    end
    
    ##################################################################################
    # Converts a Symbol to a valid log level and vise versa.
    # @return [Object] The return value is based on the argument :key.
    #                    - If you pass a Symbol, you get a log level.
    #                    - If you pass a log level, you get a Symbol.
    def self.to_severity(key)
      values = {debug: DEBUG, info: INFO, warn: WARN, error: ERROR, fatal: FATAL, unknown: UNKNOWN, system: SYSTEM}
      value = values.map.find {|value| value[key.kind_of?(Symbol) ? 0 : 1].eql?(key)}
      return value.blank? ? nil : value[key.kind_of?(Symbol) ? 1 : 0]
    end

    ##################################################################################
    # Sets the logging level for the ducklog.
    # @param [Symbol, Number] key A value representing the desired logging level.  Can be a Symbol such as :debug, :info, etc.
    #                 or an ActiveSupport::BufferedLogger Constant DEBUG, INFO, etc.
    # @return [Number]
    def self.log_level=(key)
      key = key.blank? ? "" : key.to_sym
      value = self.to_severity(key)

      unless value.blank?
        @@log_level = value
        value = value.eql?(SYSTEM) ? DEBUG : value
        self.ducklog.level = value
      end

    end

    ##################################################################################
    # Gets the current logging level for the ducklog.
    # @return [Number]
    def self.log_level
      @@log_level ||= self.ducklog.level
      return @@log_level
    end

    ##################################################################################
    # ...
    def console(msg = nil, progname = nil, &block)
      STDOUT.puts msg
      add(INFO, "#{Config.framework_name.to_s.rjust(15)}: #{msg}", progname, &block)
      return nil
    end

    ##################################################################################
    # ...
    def exception(exception, progname = nil, &block)
      STDOUT.puts %(ERROR!! ducktest.log for: #{exception})
      #if self.class.log_level.eql?(DEBUG)
        exception.backtrace.each {|x| STDOUT.puts x}
      #end
      add(ERROR, "#{Config.framework_name.to_s.rjust(15)}: #{exception.to_s}", progname, &block)
      exception.backtrace.each {|x| add(ERROR, x, progname, &block)}
      return nil
    end

    ##################################################################################
    # ...
    def debug(msg = nil, progname = nil, &block)
      add(DEBUG, "#{Config.framework_name.to_s.rjust(15)}: #{msg}", progname, &block)
      return nil
    end

    ##################################################################################
    # ...
    def info(msg = nil, progname = nil, &block)
      add(INFO, "#{Config.framework_name.to_s.rjust(15)}: #{msg}", progname, &block)
      return nil
    end

    ##################################################################################
    # ...
    def system(msg = nil, progname = nil, &block)
      if self.class.log_level.eql?(SYSTEM)
        add(DEBUG, "#{Config.framework_name.to_s.rjust(15)}: #{msg}", progname, &block)
      end
      return nil
    end

  end
end

# could be useful for adding colored logging later.
# CLEAR   = "\e[0m"
# BOLD    = "\e[1m"
#
# # Colors
# BLACK   = "\e[30m"
# RED     = "\e[31m"
# GREEN   = "\e[32m"
# YELLOW  = "\e[33m"
# BLUE    = "\e[34m"
# MAGENTA = "\e[35m"
# CYAN    = "\e[36m"
# WHITE   = "\e[37m"
#
# #############################################################################################
# def color(text, color, bold=false)
#   color = self.class.const_get(color.to_s.upcase) if color.is_a?(Symbol)
#   bold  = bold ? BOLD : ""
#   return "#{bold}#{color}#{text}#{CLEAR}"
# end
#
#   puts "Database Name: #{color(database, CYAN, true)}"
#   puts "    User Name: #{color(user_name, CYAN, true)}"
