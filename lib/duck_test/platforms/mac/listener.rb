require 'digest/sha1'

module DuckTest
  module Platforms
    module Mac

      ##################################################################################
      # Listener that wraps the native file system notifier for the Mac.
      class Listener
        include DuckTest::LoggerHelper
        include DuckTest::Platforms::Listener

        attr_accessor :thread
        attr_accessor :mechanism

        ##################################################################################
        def initialize
          super()
          ducklog.console "Platform listener: Mac"
        end

        ##################################################################################
        def self.available?
          return defined?(FSEvent)
        end

        ##################################################################################
        def start

          self.thread = Thread.new do

            self.mechanism = FSEvent.new

            self.mechanism.watch self.dir_list do |dir|
              if dir.kind_of?(Array) && dir.length > 0
                dir_spec = dir.first.to_s
                # couldn't make this work using File::SEPARATOR
                # look at it again later
                if dir_spec =~ /\/$/
                  dir_spec = dir_spec.slice(0, dir_spec.length - 1)
                end

                changed_files = self.changed_files(dir_spec)
                update_all
                changed_files.each do |item|
                  self.call_listener_event(WatchEvent.new(self, item, :update, nil))
                end

              end
            end

            until self.stop do

              self.mechanism.run
              sleep(self.speed)

            end

          end

        end

      end
    end
  end
end













