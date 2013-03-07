module DuckTest
  module Platforms

    ##################################################################################
    # Data and methods for implementing a listener.  Take a look at {Generic::Listener} for an example
    # of how to implement a custom listener.
    #
    # Basically, {DuckTest::FrameWork::FileManager} will...
    # - instantiate a listener object.
    # - assign a listener_event block to call when a directory / file changes
    # - call listener.watch(file_spec) for each directory / file that should be watched.
    # - call the start method on the listener to begin the listening thread.
    # 
    # At this point, it is the listeners responsibility to notify the file manager of changed files.  {Generic::Listener}
    # uses {#refresh} to interrogate the file system for deleted, changed, and new files and will return a list
    # of changed and new files and call the event listener block for each.
    #
    module Listener
      extend DuckTest::LoggerHelper

      attr_accessor :block

      ##################################################################################
      # Maintains an array of file spec that are directories ONLY.  Directories are tracked via {#file_list}, however, this addiontal list
      # is used for a couple of reasons.
      # 1. It is an Array instead of a Hash making the logic to interrogate the directory structure for changed files a little faster
      #    and simpler.
      # 2. Conveinent for listeners using a code base native to the operating system that tracks changes based on directories instead of individual files.  rb-fsevent and rb-fchange are
      #    examples.  Listeners of this type can simply call {#changed_files} to get a list of changed files for the directory in question.
      # @return [Array] The current list of watched directories.
      def dir_list
        @dir_list ||= []
        return @dir_list
      end

      ##################################################################################
      # Maintains a Hash of full file specs representing all directories / files being watched.  File spec is a full path and file name
      # that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename} and is used as a key to find all of the attributes
      # associated with file spec.
      #
      #   file_spec = "/home/my_home/test.com/test/unit"
      #   self.file_list[file_spec]    # => {:mtime=>1327192086.4123762, :is_dir=>true}
      #
      #   file_spec = "/home/my_home/test.com/test/unit/book_spec.rb"
      #   self.file_list[file_spec]    # => {:mtime=>1327283977.2120826, :sha=>"da39a3ee5e6b4b0d3255bfef95601890afd80709"}
      #
      #   FileUtils.touch "/home/my_home/test.com/test/unit/book_spec.rb"
      #   self.file_list[file_spec]    # => {:mtime=>1327283977.2120826, :sha=>"da39a3ee5e6b4b0d3255bfef95601890afd80709", :changed => true}
      #
      # @return [Hash] The full Hash of file specs being watched.
      def file_list
        @file_list ||= {}
        return @file_list
      end

      ##################################################################################
      # Sets the block that will be executed by the listener when a file event occurs.
      # @param [Proc] block - The block to execute.
      # @return [Proc]
      def listener_event(&block)
        self.block = block if block_given?
        return self.block
      end

      ##################################################################################
      # Executes the block assigned via {Listener#listener_event}
      # @param [WatchEvent] event A {WatchEvent} object that will be passed to the block when executed.
      # @return [Object] The value returned by the block.
      def call_listener_event(event)
        value = nil

        begin

          unless self.block.blank?
            value = self.block.call event
          end

        rescue Exception => e
          ducklog.exception e
        end

        return value
      end

      ##################################################################################
      # This method is intended to be overridden by the implementing class.
      # @return [NilClass]
      def start
        Kernel.trap("INT") do
          self.stop = true
        end
      end

      ##################################################################################
      # The stop attribute is intended to be used by listeners to control a thread loop
      # while listening for changes to directories / files.
      # @return [Boolean] True if the listener should stop listening, otherwise, false.
      def stop
        @stop = false unless defined?(@stop)
        return @stop
      end

      # Sets the stop attribute.
      def stop=(value)
        @stop = value
      end

      ##################################################################################
      # The speed value is intended for use within the thread loop that listens for changes to directories / files.
      # @return [Number] The current value of speed.
      def speed
        @speed = 1 unless defined?(@speed)
        return @speed
      end

      # Sets the speed attribute.
      def speed=(value)
        @speed = value
      end

      ##################################################################################
      # @note Be sure to call {#watch_file_spec} if you override this method.
      # Instructs the listener to watch a file spec via a call to {#watch_file_spec}
      # @param [String] file_spec See {#watch_file_spec}
      # @return [NilClass]
      def watch(file_spec)
        watch_file_spec(file_spec)
      end

      ##################################################################################
      # Instructs the listener to watch a file spec.  File should be a full path and can be a directory or file.  The file spec is tracked internally
      # and methods of this module can be used to interrogate the status and attributes of a file.  mtime, sha, changed, etc.
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [NilClass]
      def watch_file_spec(file_spec)
        update_file_spec(file_spec) unless self.watched?(file_spec)
        return nil
      end

      ##################################################################################
      # Determines if a file_spec is being watched.  File spec can be a directory or file and should included full path.
      #
      #   file_spec = "/home/my_home/test.com/test/unit"
      #   watch(file_spec)
      #   puts watched?(file_spec)    # => true
      #
      #   file_spec = "/home/my_home/test.com/test/unit/book_spec.rb"
      #   watch(file_spec)
      #   puts watched?(file_spec)    # => true
      #
      #   file_spec = "/home/my_home/test.com/test/unit/bike_spec.rb"
      #   puts watched?(file_spec)    # => false
      #
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [Boolean] Returns true if file_spec is being watched.
      def watched?(file_spec)
        return self.file_list[file_spec] ? true : false
      end

      ##################################################################################
      # Determines if a directory / file has changed.
      #
      #   file_spec = "/home/my_home/test.com/test/unit/bike_spec.rb"
      #   watched?(file_spec)   # => false  should not be considered changed unless watched
      #
      #   file_spec = "/home/my_home/test.com/test/unit/bike_spec.rb"
      #   watch(file_spec)
      #   watched?(file_spec)   # => false  not changed yet
      #
      #   file_spec = "/home/my_home/test.com/test/unit/bike_spec.rb"
      #   watch(file_spec)
      #   watched?(file_spec)   # => false  not changed yet
      #   FileUtils.touch(file_spec)
      #   watched?(file_spec)   # => true
      #
      # @return [Boolean] Returns true if file_spec has changed.
      def changed?(file_spec)
        value = false

        # must have a valid file object.
        file_object = self.file_list[file_spec]
        if file_object

          # no SHA for directories
          if file_object[:is_dir]
            value = File.mtime(file_spec).to_f > file_object[:mtime]
          else
            value = File.mtime(file_spec).to_f > file_object[:mtime] || !Digest::SHA1.file(file_spec).to_s.eql?(file_object[:sha])
          end

        end
        return value
      end

      ##################################################################################
      # Updates all of the tracked attributes of a watched directory / file.  This method is called by methods such as {#watch} and {#watch_file_spec} to obtain
      # attributes about a directory / file and store them for later use.
      #
      #   file_spec = "/home/my_home/test.com/test/unit"
      #   update_file_spec(file_spec)
      #   puts file_list(file_spec)    # => {:mtime=>1327290092.5563293, :is_dir=>true}
      #
      #   file_spec = "/home/my_home/test.com/test/unit/book_spec.rb"
      #   update_file_spec(file_spec)
      #   puts file_list(file_spec)    # => {:mtime=>1327290031.8203268, :sha=>"da39a3ee5e6b4b0d3255bfef95601890afd80709"}
      #
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [NilClass]
      def update_file_spec(file_spec)
        buffer = {}

        buffer[:mtime] = File.mtime(file_spec).to_f

        if File.directory?(file_spec)
          buffer[:is_dir] = true
          self.dir_list.push(file_spec) unless self.dir_list.include?(file_spec)
        else
          # assume it is a file if not a directory
          buffer[:sha] = Digest::SHA1.file(file_spec).to_s
        end

        self.file_list[file_spec] = buffer

        return nil
      end

      ##################################################################################
      # Updates all of tracked attributes for all directories / files being watched.
      # Since this method calls {#update_file_spec}, all of the existing attributes will be replaced, therefore,
      # addiontal attributes such as :changed true/false will be wiped out.
      # @return [NilClass]
      def update_all
        self.file_list.each do |item|
          update_file_spec(item.first)
        end
        return nil
      end

      ##################################################################################
      # Traverses all watched directories and builds a list of all changed files.  It does not include directories in the returned list.
      # refresh loops thru all of the items in {#dir_list} and calls {#changed_files} for each of them.
      # @return [Array]  Returns changed files
      def refresh
        list = []
        index = 0

        # remove directories / files from the internal lists that no longer exist on disk.
        self.file_list.each do |file_object|
          unless File.exist?(file_object.first)
            if file_object.last[:is_dir]
              self.dir_list.delete(file_object.first)
            end
            self.file_list.delete(file_object.first)
          end
        end

        while index < self.dir_list.length
          list.concat(self.changed_files(self.dir_list[index]))
          index += 1

        end

        return list
      end

      ##################################################################################
      # Returns changed files within a single directory.  This method is intended to be used by listeners that process a single directory as opposed
      # to single files.
      #
      # what does this thing do?
      # - get a list of all the directories / files within the requested directory specified by file_spec
      # - loop thru each directory / file in the list
      #   - each directory / file is added to the watch list.  this should cover directories / files that are added after the listener has been started.
      #   - directories are not added to the return list.
      #   - if the file being compared is not currently watched or if {#changed?} says it has been changed, then, the file spec is added to the return list.
      #
      # @param [String] file_spec A file spec that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}, however,
      #                           the actual file name should be excluded.  ONLY the path should be passed.
      # @return [Array]  Returns changed files
      def changed_files(file_spec)
        list = []

        file_list = Dir.glob(File.join(file_spec, "*"))
        file_list.each do |file_spec|

          currently_watched = self.watched?(file_spec)
          # ensure the directory / file is being watched
          # a new directory / file could have been added by the user
          self.watch_file_spec(file_spec)

          unless File.directory?(file_spec)
            if !currently_watched || self.changed?(file_spec)
              list.push(file_spec)
            end
          end
        end

        return list
      end

    end
  end
end
