module DuckTest
  module Platforms

    # Conveinence methods to include in classes that need to determine current platform.
    # Method calls are relative to {OSHelper OSHelper}
    module OSHelpers

      ##################################################################################
      # Conveinence method that calls {OSHelper.is_linux?}
      def is_linux?
        OSHelper.is_linux?
      end

      ##################################################################################
      # Conveinence method that calls {OSHelper.is_mac?}
      def is_mac?
        OSHelper.is_mac?
      end

      ##################################################################################
      # Conveinence method that calls {OSHelper.is_windows?}
      def is_windows?
        OSHelper.is_windows?
      end

      ##################################################################################
      # Conveinence method that calls {OSHelper.available?}
      def available?
        OSHelper.available?
      end

      ##################################################################################
      # Conveinence method that calls {OSHelper.current_os}
      def current_os
        OSHelper.current_os
      end

    end

    # Methods used to determine the current operating system platform.
    class OSHelper

      ##################################################################################
      # Determines if the current operating system is: Linux
      # @return [Boolean] Returns true if the current operating system is: Linux
      def self.is_linux?
        RUBY_PLATFORM =~ /linux/i
      end

      ##################################################################################
      # Determines if the current operating system is: Macintosh
      # @return [Boolean] Returns true if the current operating system is: Macintosh
      def self.is_mac?
        RUBY_PLATFORM =~ /darwin/i
      end

      ##################################################################################
      # Determines if the current operating system is: Windoze
      # @return [Boolean] Returns true if the current operating system is: Windoze
      def self.is_windows?
        RUBY_PLATFORM =~ /mswin|mingw/i
      end

      ##################################################################################
      # Determines if a native listener is available for the current platform.
      # @return [Boolean] Returns true if the listener is available.
      def self.available?
        if self.is_linux?
          return Platforms::Linux::Listener.available?

        elsif self.is_mac?
          return Platforms::Mac::Listener.available?

        elsif self.is_windows?
          return Platforms::Windows::Listener.available?

        end

        return false
      end

      ##################################################################################
      # Returns a Symbol indicating the current operating system.
      #
      # Currently returns one of four possible values:
      #   :linux
      #   :mac
      #   :windows
      #   :unknown
      #
      # @return [Symbol]
      def self.current_os
        return :linux if self.is_linux?
        return :mac if self.is_mac?
        return :windows if self.is_windows?
        return :unknown
      end

    end

  end
end
