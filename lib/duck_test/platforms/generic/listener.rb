module DuckTest
  module Platforms
    module Generic

      ##################################################################################
      # A generic listener to watch for changed, deleted, and new files on a file system.
      class Listener
        include DuckTest::LoggerHelper
        include DuckTest::Platforms::Listener
        include DuckTest::Platforms::OSHelpers

        attr_accessor :thread

        ##################################################################################
        def initialize
          super

          ducklog.console "Platform listener: Generic"

          # i plan to implement feature to allow developer to specify which
          # listener to use, so, simply notify developer how to enable native listener
          # if it is not available.
          if self.is_linux? && !self.available?
            ducklog.console "########################################################################"
            ducklog.console "NOTE: Native file listener is NOT enabled."
            ducklog.console "To enable native file listener:"
            ducklog.console "Edit your Gemfile and add the following to your test group"
            ducklog.console "gem 'rb-inotify'"
            ducklog.console "########################################################################"

          elsif self.is_mac? && !self.available?
            ducklog.console "########################################################################"
            ducklog.console "NOTE: Native file listener is NOT enabled."
            ducklog.console "To enable native file listener:"
            ducklog.console "Edit your Gemfile and add the following to your test group"
            ducklog.console "gem 'rb-fsevent'"
            ducklog.console "########################################################################"


          elsif self.is_windows? && !self.available?
            ducklog.console "########################################################################"
            ducklog.console "NOTE: Native file listener is NOT enabled."
            ducklog.console "To enable native file listener:"
            ducklog.console "Edit your Gemfile and add the following to your test group"
            ducklog.console "gem 'rb-fchange'"
            ducklog.console "########################################################################"


          end

        end

        ##################################################################################
        # Starts a thread and listens for changes to all of the directories / files added to the listener
        # via {DuckTest::Platforms::Listener#watch}
        # @return [NilClass]
        def start

          # call super to trap control-C
          super

          # call refresh once prior to starting the loop so that all of the attributes
          # for all directories / files get updated.
          self.refresh

          # now, start the thread
          self.thread = Thread.new do

            until self.stop do

              sleep(self.speed)

              # grab a list of all changed and new files
              changed_files = self.refresh

              # now, update all of the attributes for all directories / files so the
              # next interation of the loop will not return invalid results.
              update_all

              # call the event listener block for all of the changed / new files
              changed_files.each do |item|
                self.call_listener_event(WatchEvent.new(self, item, :update, nil))
              end

            end

          end

          return nil
        end

      end

    end
  end
end








