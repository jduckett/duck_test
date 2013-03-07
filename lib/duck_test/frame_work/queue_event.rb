module DuckTest
  module FrameWork

    # A QueueEvent is triggered when directories / files have changed and contains a list of the files that have changed.
    class QueueEvent

      # See {#initialize}
      attr_accessor :source

      # See {#initialize}
      attr_accessor :files

      ##################################################################################
      # Initialize a new QueueEvent
      # @param [Object] source    A reference to the calling object.
      # @param [Array] files      A list of files that have changed and require action.
      # @return [QueueEvent]
      def initialize(source, files)
        super()

        self.source = source
        self.files = files.uniq

        return self
      end

    end
  end
end
