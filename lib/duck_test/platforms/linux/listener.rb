module DuckTest
  module Platforms
    module Linux

      ##################################################################################
      # Listener that wraps the native file system notifier for Linux.
      class Listener
        include DuckTest::LoggerHelper
        include DuckTest::Platforms::Listener

        attr_accessor :thread
        attr_accessor :mechanism

        ##################################################################################
        def initialize
          super()
          self.mechanism = INotify::Notifier.new
        end

        ##################################################################################
        def self.available?
          return defined?(INotify::Notifier)
        end

        ##################################################################################
        def start

          self.thread = Thread.new do
            until self.stop do
              self.mechanism.process
              sleep(self.speed)
            end
          end

        end

        ##################################################################################
        def watch(file_spec)

          self.mechanism.watch file_spec, :close_write, :moved_from, :moved_to, :create, :delete, :delete_self do |event|

            value = :unknown

            event.flags.each do |flag|
              value = flag == :close_write ? :update : value
              value = flag == :create ? :create : value
              value = flag == :delete || flag == :delete_self ? :destroy : value
              value = flag == :moved_from || flag == :moved_from ? :move : value
              break unless value == :unknown
            end

            unless value == :unknown
              self.call_listener_event(WatchEvent.new(self, event.absolute_name, value, event))
            end

          end

        end

      end
    end
  end
end













