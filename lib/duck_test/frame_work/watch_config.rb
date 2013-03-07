module DuckTest
  module FrameWork


    # A WatchConfig represents a single watch definition including attributes such as pattern, filter sets, mappings, etc.
    #
    #  DuckTest.config do
    #  
    #    runnable "**/*"    # this would represent a WatchConfig object.
    #    
    #  end
    class WatchConfig
      include DuckTest::ConfigHelper

      # See {DuckTest::ConfigHelper#autorun}
      attr_accessor :autorun

      # See {#initialize}
      attr_accessor :filter_set

      # See {#initialize}
      attr_accessor :maps

      # See {#initialize}
      attr_accessor :pattern

      # See {#initialize}
      attr_accessor :runnable

      alias :autorun? :autorun
      alias :runnable? :runnable

      ##################################################################################
      # Initialize a new WatchConfig
      # @param [Hash] options                                           An options Hash containing values used to initialize the object.
      # @option options [Symbol] :autorun                               See {DuckTest::ConfigHelper#autorun}
      # @option options [String] :watch_basedir                         See {DuckTest::ConfigHelper#watch_basedir}
      # @option options [DuckTest::FrameWork::FilterSet] :filter_set    See {DuckTest::FrameWork::FilterSet}
      # @option options [Array] :maps                                   See {DuckTest::FrameWork::Map}
      # @option options [String] :pattern                               See {DuckTest::Config#watch}
      # @option options [Boolean] :runnable                             Boolean indicating if the files watch by this WatchConfig are runnable test files.
      # @option options [String] :runnable_basedir                      See {DuckTest::ConfigHelper#runnable_basedir}
      # @return [WatchConfig]
      def initialize(options = {})
        super()

        self.autorun = options[:autorun]
        self.autorun = false if self.autorun.nil?

        self.watch_basedir = options[:watch_basedir]

        self.filter_set = options[:filter_set] unless options[:filter_set].blank?
        self.filter_set = FilterSet.new(options) if self.filter_set.blank?

        self.maps = options[:maps] unless options[:maps].blank?
        self.maps = [] if self.maps.blank?

        self.pattern = options[:pattern]
        self.runnable = options[:runnable]
        self.runnable = false if self.runnable.nil?

        self.runnable_basedir = options[:runnable_basedir]

        return self
      end

    end
  end
end
