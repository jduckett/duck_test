module DuckTest
  # ...
  module FrameWork

    ##################################################################################
    # {include:file:MAPS.md}
    class Map
      include DuckTest::ConfigHelper

      # An Array of {Map} objects representing target runnables tests.
      attr_accessor :maps

      ##################################################################################
      # Initialize a new Map.  A Map can be initialized in multiple variations.
      # sub_directory and file_name are defaulted to nil, therefore, those values are optional.  However, the
      # gotcha is that you cannot specify file_name without first specifying sub_directory which make the order of
      # the arguments important.  If you omit file_name or sub_directory and file_name initialize will recognize
      # it by checking the sub_directory and file_name arguments.  If either of them are a Hash, then, it assumes
      # that value is the options Hash.
      #
      #   # normal form
      #   Map.new(/models/, /bike/, watch_basedir: :app, runnable_basedir: :test)
      #
      #   # specify sub_directory and options
      #   Map.new(/models/, watch_basedir: :app, runnable_basedir: :test)
      #
      #   # options only
      #   Map.new(watch_basedir: :app, runnable_basedir: :test)
      #
      # Any value passed as part of the options Hash will override the preceding sub_directory or file_name value set by a normal argument.
      # 
      #   # specify all arguments as part of the options Hash
      #   Map.new(sub_directory: /models/, file_name: /bike/, watch_basedir: :app, runnable_basedir: :test)
      #
      # Since {DuckTest::Config} uses the Map class directly for creating Map objects this feature
      # should allow developer to create maps in the config file like the following:
      # 
      #   DuckTest.config do
      #     watch "**/*" do
      #       map /models/, /bike/
      #     end
      #   end
      # 
      # If a block is passed, it is executed against self.  Therefore, all of the instance methods are available to be called within the block.
      #
      #   Map.new(/^models/, /[a-z]_store/, watch_basedir: :app) do
      #     target /^unit/, /[a-z]_spec.rb/, watch_basedir: :spec
      #     target /^functional/, /[a-z]_controller_[a-z]/, watch_basedir: :test
      #   end
      # 
      # @param [Proc, Regexp, Symbol, String] sub_directory     See {#sub_directory}
      # @param [Proc, Regexp, Symbol, String] file_name         See {#file_name}
      # @param [Hash] options                                   An options Hash containing values used to initialize the object.
      # @option options [String] :file_name                     See {#file_name}
      # @option options [String] :runnable_basedir              See {DuckTest::ConfigHelper#runnable_basedir}
      # @option options [String] :sub_directory                 See {#sub_directory}
      # @option options [String] :watch_basedir                 See {DuckTest::ConfigHelper#watch_basedir}
      # @param [Block] block                                    A standard Ruby code block.
      # @return [Map]
      def initialize(sub_directory = nil, file_name = nil, options = {}, &block)
        super()

        options = sub_directory.kind_of?(Hash) ? sub_directory : options
        options = file_name.kind_of?(Hash) ? file_name : options

        self.watch_basedir = options[:watch_basedir]

        self.file_name file_name unless file_name.blank? || file_name.kind_of?(Hash)
        self.file_name options[:file_name] unless options[:file_name].blank?

        self.maps = [] # don't accept a maps array as a parameter

        self.sub_directory sub_directory unless sub_directory.blank? || sub_directory.kind_of?(Hash)
        self.sub_directory options[:sub_directory] unless options[:sub_directory].blank?

        self.runnable_basedir = options[:runnable_basedir]

        self.instance_exec(&block) if block_given?
        return self
      end

      ##################################################################################
      # Creates a new Map object based on options and adds it to self.  Must be called within a {#initialize} block.
      #
      #   # in block form
      #   Map.new(/^models/, /[a-z]_store/, watch_basedir: :app).build do
      #     target /^functional/, /[a-z]_controller_[a-z]/              # runnable_basedir trickles down to watch_basedir
      #     target /^unit/, /[a-z]_spec.rb/, watch_basedir: :spec       # overrides tickled runnable_basedir
      #   end
      #
      # It is important to note that the runnable_basedir is passed to the target block as watch_basedir.  This allows
      # you to specify a runnable_basedir to the Map object and have it trickle down to all of the targets eliminating the
      # need to specify it for every target block.  Also, {DuckTest::Config} will use this feature by allowing you to specify
      # watch_basedir and runnable_basedir at the top of a config file and have those values be used for all mappings.
      #
      # @param [Hash] options  See {#initialize}
      # @param [Block] block  A standard Ruby code block.
      # @return [Map] The recently created Map object.
      def target(sub_directory = nil, file_name = nil, options = {}, &block)
        options = sub_directory.kind_of?(Hash) ? sub_directory : options
        options = file_name.kind_of?(Hash) ? file_name : options
        config = {watch_basedir: self.runnable_basedir}.merge(options)
        self.maps.push(Map.new(sub_directory, file_name, config, &block))
        return self.maps.last
      end

      ##################################################################################
      # @note See {Map} overview for details on how Regexp, String, Symbols are evaluated and a general understanding of mappings.
      # Sets the current value of the file name expression.
      # See {#file_name_match?}
      # @param [Array, Proc, Regexp, String, Symbol] value      An expression to compare against file names.
      #                                                         If the value is an Array, then, file_name expects the Array to contain
      #                                                         Procs, Regexps, Strings, or Symbols and not sub-arrays.
      # @return [Array, Proc, Regexp, String, Symbol] value     Returns the current value of the file_name expression.
      def file_name(value = nil, &block)
        @file_name ||= "all"
        value = value.kind_of?(Symbol) ? value.to_s : value
        if value.kind_of?(Array)
          value.each_with_index {|item, index| value[index] = item.to_s if item.kind_of?(Symbol)}
        end
        @file_name = value unless value.blank?
        @file_name = block if block_given?
        return @file_name
      end

      ##################################################################################
      # @note See {Map} overview for details on how Regexp, String, Symbols are evaluated and a general understanding of mappings.
      # The current {#file_name} value should be an expression Proc, Regexp, or String.  This value is compared against file names
      # retrieved from the file system based on the pattern option of {DuckTest::Config#watch}.
      #
      #   map = Map.new
      #   map.file_name(/^bike/)
      #   map.file_name_match?("bike_spec.rb")          # => true
      #   map.file_name_match?("truck_spec.rb")         # => false
      #
      # @param [String] value  The file name being evaluated.  Typically, this is the source or target file name.
      # @param [String] cargo   A value that is passed to the block if {#file_name} is a block.
      # @return [Boolean] True if match, otherwise, false.
      def file_name_match?(value, cargo = nil)
        result = false
        expressions = self.file_name.blank? ? "all" : self.file_name
        expressions = expressions.kind_of?(Array) ? self.file_name : [self.file_name]

        expressions.each do |expression|

          if expression.kind_of?(Regexp)
            result = value =~ expression

          elsif expression.kind_of?(String)
            result = value =~ /^#{expression}/ || expression.eql?("all")

          elsif expression.kind_of?(Proc)
            result = expression.call value, cargo

          end

          break if result
        end

        return result
      end

      ##################################################################################
      # @note See {Map} overview for details on how Regexp, String, Symbols are evaluated and a general understanding of mappings.
      # Sets the current value of the sub-directory expression.
      # See {#sub_directory_match?}
      # @param [Array, Proc, Regexp, String, Symbol] value      An expression to compare against directory names.
      #                                                         If the value is an Array, then, sub_directory expects the Array to contain
      #                                                         Procs, Regexps, Strings, or Symbols and not sub-arrays.
      # @return [Array, Proc, Regexp, String, Symbol] value     Returns the current value of the sub_directory expression.
      def sub_directory(value = nil, &block)
        @sub_directory ||= "all"
        value = value.kind_of?(Symbol) ? value.to_s : value
        if value.kind_of?(Array)
          value.each_with_index {|item, index| value[index] = item.to_s if item.kind_of?(Symbol)}
        end
        @sub_directory = value unless value.blank?
        @sub_directory = block if block_given?
        return @sub_directory
      end

      ##################################################################################
      def match?(target)
        value = false
        
        if self.match.kind_of?(Proc)
          value = self.match.call target
        else
          value = self.sub_directory_match?(target[:sub_directory]) && self.file_name_match?(target[:file_name]) ? true : value
        end
        
        return value
      end

      ##################################################################################
      def match_target?(target, source)
        value = false

        if self.match.kind_of?(Proc)
          value = self.match.call target, source
        else
          value = self.sub_directory_match?(target[:sub_directory]) && self.file_name_match?(target[:file_name], source[:file_name])
        end

        return value
      end

      ##################################################################################
      def match(&block)
        @match ||= nil
        @match = block if block_given?
        return @match
      end

      ##################################################################################
      # @note See {Map} overview for details on how Regexp, String, Symbols are evaluated and a general understanding of mappings.
      # The current {#sub_directory} value should be an expression Proc, Regexp, or String.  This value is compared against directory paths
      # retrieved from the file system based on the pattern option of {DuckTest::Config#watch}.
      # 
      # Examples:
      #
      #   map = Map.new sub_directory: :models
      #   map.sub_directory_match?("models")                     # => true
      #   map.sub_directory_match?("controllers")                # => false
      #
      #   map = Map.new sub_directory: "models"
      #   map.sub_directory_match?("models")                     # => true
      #   map.sub_directory_match?("controllers")                # => false
      #
      #   map = Map.new sub_directory: /models/
      #   map.sub_directory_match?("models")                     # => true
      #   map.sub_directory_match?("controllers")                # => false
      #
      #   map = Map.new sub_directory: :models, watch_basedir: :app
      #   map.sub_directory_match?("app/models")                 # => true
      #   map.sub_directory_match?("app/models/sec")             # => true
      #   map.sub_directory_match?("my_app/models")              # => false
      #   map.sub_directory_match?("my_app/models/sec")          # => false
      #   map.sub_directory_match?("app/controllers")            # => false
      #
      #   map = Map.new sub_directory: "models", watch_basedir: :app
      #   map.sub_directory_match?("app/models")                 # => true
      #   map.sub_directory_match?("app/models/sec")             # => true
      #   map.sub_directory_match?("my_app/models")              # => false
      #   map.sub_directory_match?("my_app/models/sec")          # => false
      #   map.sub_directory_match?("app/controllers")            # => false
      #
      #   map = Map.new sub_directory: /^models/, watch_basedir: :app
      #   map.sub_directory_match?("app/models")                 # => true
      #   map.sub_directory_match?("app/models/sec")             # => true
      #   map.sub_directory_match?("my_app/models")              # => false
      #   map.sub_directory_match?("my_app/models/sec")          # => false
      #   map.sub_directory_match?("app/controllers")            # => false
      #
      #   map = Map.new sub_directory: /models/, watch_basedir: :app
      #   map.sub_directory_match?("app/models")                 # => true
      #   map.sub_directory_match?("app/models/sec")             # => true
      #   map.sub_directory_match?("my_app/models")              # => true
      #   map.sub_directory_match?("my_app/models/sec")          # => true
      #   map.sub_directory_match?("app/controllers")            # => false
      #
      # @param [String] value  The file name being evaluated.  Typically, this is the source or target file name.
      # @param [String] cargo   A value that is passed to the block if {#sub_directory} is a block.
      # @return [Boolean] True if match, otherwise, false.
      def sub_directory_match?(value, cargo = nil)
        result = false
        expressions = self.sub_directory.blank? ? "all" : self.sub_directory
        expressions = expressions.kind_of?(Array) ? self.sub_directory : [self.sub_directory]

        # the value being compared via this method is expecting to be a directory
        # possibly containing path separators.  The following expressions interrogate
        # value for the existence of the current value of self.watch_basedir.  If it exists, then,
        # it is removed, otherwise, value is left in tact.
        # The reason for this is that runnable and watch definitions require a pattern
        # to retrieve files.  The self.watch_basedir provides the developer with the conveience
        # of not having to include the watch_basedir directory in all of the mappings.
        # see the description and examples under the watch_basedir method.

        # first look for watch_basedir with SEPARATOR appended to it: "models/"
        unless self.watch_basedir.blank?
          if value =~ /^#{%(#{self.watch_basedir}#{File::SEPARATOR})}/
            value = value.gsub(%(#{self.watch_basedir}#{File::SEPARATOR}), "")

          elsif value =~ /^#{self.watch_basedir}/
            value = value.gsub(self.watch_basedir, "")

          end
        end

        expressions.each do |expression|

          if expression.kind_of?(Regexp)
            result = value =~ expression

          elsif expression.kind_of?(String)
            result = value =~ /^#{expression}/ || expression.eql?("all")

          elsif expression.kind_of?(Proc)
            result = expression.call value, cargo

          end

          break if result
        end

        return result
      end

      ##################################################################################
      # Determines if the current {Map} object is valid by examining the sub_directory and file_name values.
      # Both value must not be nil to be valid.
      # @return [Boolean] Returns true if valid, otherwise, false
      def valid?
        return !self.sub_directory.blank? && !self.file_name.blank?
      end

      ##################################################################################
      # ...
      def to_s(margin = "")
        buffer = ""
        self.maps.each do |item|
          buffer = "\r\n#{margin}  maps:" if buffer.blank?
          buffer += "\r\n#{margin}#{item.to_s('  ')}"
        end
        buffer_basedir = self.watch_basedir.blank? ? "" : self.watch_basedir.ljust(15)
        return "\r\n#{margin}watch_basedir: #{buffer_basedir} runnable_basedir: #{self.runnable_basedir}\r\n#{margin}sub_directory: #{self.sub_directory} file_name: #{self.file_name}#{buffer}"
      end

    end
  end
end
