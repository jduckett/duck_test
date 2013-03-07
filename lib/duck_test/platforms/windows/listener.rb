# TODO needs to be refactored like the mac listener
require 'digest/sha1'

module DuckTest
  module Platforms
    module Windows

      ##################################################################################
      # Listener that wraps the native file system notifier for Windows.
      class Listener
        include DuckTest::LoggerHelper
        include DuckTest::Platforms::Listener

        attr_accessor :thread
        attr_accessor :mechanism

        ##################################################################################
        def initialize
          super()
          self.mechanism = FChange::Notifier.new
          ducklog.console "Platform listener: Windows"
        end

        ##################################################################################
        def self.available?
          return defined?(FChange::Notifier)
        end

        ##################################################################################
        def file_list
          @file_list ||= {}
          return @file_list
        end

        ##################################################################################
        def watched?(file_spec)
          return self.file_list[file_spec] ? true : false
        end
        
        ##################################################################################
        def changed?(file_spec)
          value = false
          file_object = self.file_list[file_spec]
          if file_object && !file_object[:is_dir]
            value = File.mtime(file_spec).to_f > file_object[:mtime] || !Digest::SHA1.file(file_spec).to_s.eql?(file_object[:sha])
          end
          return value
        end
        
        ##################################################################################
        def watch_file_spec(file_spec)
          buffer = {}
          buffer[:is_dir] = File.directory?(file_spec)
          buffer[:mtime] = File.mtime(file_spec).to_f
          buffer[:sha] = Digest::SHA1.file(file_spec).to_s unless buffer[:is_dir]
          self.file_list[file_spec] = buffer
        end

        ##################################################################################
        def start

          self.file_list.each do |file_object|

            if file_object.last[:is_dir]

              @mechanism.watch file_object.first, :all_events, :recursive do |dir|

                  dir_spec = dir.watcher.path
                  if self.watched?(dir_spec)
                    changed_files = []
                    list = Dir.glob "#{dir_spec}/*"
                    list.each do |item|
                      if self.watched?(item)
                        if self.changed?(item)
                          self.watch_file_spec(item)
                          changed_files.push(item)
                        end
                      else
                        self.watch_file_spec(item)
                        changed_files.push(item)
                      end
                    end
                    changed_files.each do |item|
                      self.call_listener_event(WatchEvent.new(self, item, :update, nil))
                    end
                  end
              end

            end

          end

          self.thread = Thread.new do
            until self.stop do
              @mechanism.run
              sleep(self.speed)
            end
          end

        end

        ##################################################################################
        def watch(file_spec)
          watch_file_spec(file_spec)
        end

      end
    end
  end
end













