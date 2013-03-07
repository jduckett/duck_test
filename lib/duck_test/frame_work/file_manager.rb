module DuckTest
  module FrameWork

    # module containing data and methods for building list, resolving filters, managing all watched directories / files, etc.
    # holds the common whitelist and blacklist, watch configurations, a reference to a file listener and a runnable test queue.
    module FileManager
      include DuckTest::ConfigHelper
      include LoggerHelper
      include DuckTest::Platforms::OSHelpers

      ##################################################################################
      # Adds a file object to either the black or white list.  Both lists are actually Hashes, so,
      # the file spec is used as the key and the value is a Hash containing {WatchConfig WatchConfig}
      # and several other data elements and is stored in the target list.  The Hash associated with the file spec
      # is referred to as a "file object".  add_to_list will verify that file_spec actually exists on disk prior to adding it to either list.
      # Also, a boolean flag is set on the target Hash object indicating if file_spec is a directory.
      #
      #    watch_config = WatchConfig.new
      #    add_to_list(:white, "duck_test/spec/testdir/spec/test01.rb", watch_config)
      #    puts self.white_list # => {"/alldata/rails/gems/duck_test/spec/testdir/spec/test01.rb"=>{:watch_config=>#<DuckTest::FrameWork::WatchConfig:0x00000003451ae8>, :is_dir=>false}}
      #
      # @param [Symbol] target The target list to add the file object.
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @param [WatchConfig] config A valid {WatchConfig} object.
      # @return [NilClass]
      def add_to_list(target, file_spec, config)

        # verify the file exists prior to adding it to a list.
        if File.exist?(file_spec)
          case target
          when :black
            self.black_list[file_spec] = {watch_config: config, is_dir: File.directory?(file_spec)}

          when :white
            self.white_list[file_spec] = {watch_config: config, is_dir: File.directory?(file_spec)}

          end
        end

      end

      ##################################################################################
      # A list of file objects that have been blacklisted.  Files that are blacklisted
      # are not processed in any way.
      # @return [Hash]
      def black_list
        @black_list ||= {}
        return @black_list
      end

      ##################################################################################
      # Determines if a file object has been blacklisted.
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [Boolean] Returns true if the file has been blacklisted, otherwise, false.
      def black_listed?(file_spec)
        return self.black_list[file_spec]
      end

      ##################################################################################
      # Builds full black and white lists of directories and files based on the current list of watch_configs.
      def build_watch_lists

        begin
        
          potential_blacklist = {}

          self.watch_configs.each do |watch_config|

            ducklog.system "build_watch_lists => watch_config.pattern.blank?: #{watch_config.pattern.blank?}  #{watch_config.pattern}"

            unless watch_config.pattern.blank?

              watch_config_root = watch_config.watch_basedir

              # add the full path to all of the patterns
              patterns = []
              if watch_config.pattern.kind_of?(Array)
                watch_config.pattern.each {|pattern| patterns.push(File.expand_path(File.join(self.root, watch_config_root, pattern)))}
              else
                patterns.push(File.expand_path(File.join(self.root, watch_config_root, watch_config.pattern)))
              end

              ducklog.system "searching for: #{patterns}"

              # use the standard Dir.glob method to build a list of directories and files based on pattern
              list = Dir.glob(patterns, File::FNM_DOTMATCH)

              # i'm not sure how Dir.glob will return files on different operating systems, so, sort the array first to put the directories
              # at the top of the list.  may have to change this later to simply process and black list the directories before processing files.
              # the reason for this is so that we can black list a file if it's directory is black_listed
              list.sort!

              #process_file_list watch_config, list, :directory
              #verify_parent_directory_nodes
              #process_file_list watch_config, list, :file
              
              list.each do |file_spec|
                if File.directory?(file_spec)
                  self.watch_file_spec(file_spec, watch_config)
                end
              end

              list.each do |file_spec|
                unless File.directory?(file_spec)
                  self.watch_file_spec(file_spec, watch_config)
                end
              end

              list.each do |file_spec|
                unless self.white_listed?(file_spec)
                  potential_blacklist[file_spec] = watch_config
                end
              end

            end
          end
          
          potential_blacklist.each do |file_object|
            unless self.white_listed?(file_object.first)
              self.add_to_list(:black, file_object.first, file_object.last)
            end
          end

        rescue Exception => e
          ducklog.exception e
        end

      end

      ##################################################################################
      # Returns the parent of a file object.  File objects are stored as a file spec and an
      # associated Hash when added using {FileManager#add_to_list}.  The directory containing
      # the actual file spec is considered to be the parent of a file object.
      #
      #    # the following is a file spec considered to point to an actual file on disk.
      #    "duck_test/spec/testdir/spec/test01.rb"
      #
      #    # the following is a file spec considered to be the parent of the above file object.
      #    "duck_test/spec/testdir/spec"
      #
      # find_file_object_parent will the use dirname of the file spec to find the parent file object
      # and return the associated Hash.
      # @param [Symbol] target The target list to add the file object.
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [Hash] A file object is actually a Hash.
      def find_file_object_parent(target, file_spec)
        case target
        when :black
          return self.black_listed?(File.dirname(file_spec))

        when :white
          return self.white_listed?(File.dirname(file_spec))

        end

        return nil
      end

      ##################################################################################
      # Searches for runnable files mapped to a single non-runnable file.
      # See {file:MAPS.md} for details and examples.
      # @param [String] file_spec A full file specification including path that also adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @param [WatchConfig] watch_config The watch configuration object that is associated with the file spec within {#white_list}.
      # @return [Array] A list of runnable files.
      def find_runnable_files(file_spec, watch_config)
        list = []

        source_parts = split_file_spec(file_spec)

        watch_config.maps.each do |map|

          if map.match?(source_parts)

            self.white_list.each do |file_object|

              unless file_object.last[:is_dir] || file_object.first.eql?(file_spec)

                target_parts = split_file_spec(file_object.first)

                map.maps.each do |target_map|

                  if target_map.match_target?(target_parts, source_parts)
                    ducklog.system "find_runnable_files added: #{file_object.first}"
                    list.push(file_object.first)
                  end

                end

              end

            end

          end

        end

        return list.uniq
      end

      ##################################################################################
      # A simple Array that holds a list of all the non-runnable files that have been loaded from disk after being changed.
      # @return [Array]
      def non_loadable_history
        @non_loadable_history ||= []
        return @non_loadable_history.uniq
      end

      ##################################################################################
      # Assigns the non-runnable history array.
      # @return [Array]
      def non_loadable_history=(value)
        @non_loadable_history = value
      end

      ##################################################################################
      # A simple Array that holds a list of all the non-runnable files that have been loaded from disk after being changed.
      # @return [Array]
      def non_runnable_history
        @non_runnable_history ||= []
        return @non_runnable_history.uniq
      end

      ##################################################################################
      # Assigns the non-runnable history array.
      # @return [Array]
      def non_runnable_history=(value)
        @non_runnable_history = value
      end

      ##################################################################################
      # ...
      def process_file_list(watch_config, list, type)
        list.each do |file_spec|

          is_dir = File.directory?(file_spec)
          if (is_dir && type.eql?(:directory)) || (!is_dir && type.eql?(:file))

            if watchable?(file_spec, watch_config)
              if self.white_listed?(file_spec)
                ducklog.console "  already watching: #{file_spec}"
              else
                self.add_to_list(:white, file_spec, watch_config)
              end
            else
              # don't see the relevance of notifying the user about files that have already been blacklisted
              # maybe change it later...
              unless self.black_listed?(file_spec)
                self.add_to_list(:black, file_spec, watch_config)
              end
            end

          end

        end
      end

      ##################################################################################
      # A simple Array that holds a list of all the runnable files that have been loaded from disk after being changed.
      # @return [Array]
      def runnable_history
        @runnable_history ||= []
        return @runnable_history.uniq
      end

      ##################################################################################
      # Assigns the runnable history array.
      # @return [Array]
      def runnable_history=(value)
        @runnable_history = value
      end

      ##################################################################################
      # Splits a full file specification into several parts: Rails.root, basedir, file name
      #
      #   puts split_file_spec("/home/my_home/my_app/app/models/bike.rb")  # => {:dir_spec=>"//home/my_home/my_app", :file_name=>"bike.rb", :sub_directory=>"app/models"}
      #
      # @param [String] file_spec A full file specification including path that also adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [Array]
      def split_file_spec(file_spec)
        values = {dir_spec: File.expand_path(self.root), file_spec: file_spec}
        buffer = File.split(file_spec.gsub("#{values[:dir_spec]}#{File::SEPARATOR}", ""))
        values[:file_name] = buffer.pop
        values[:sub_directory] = File.join(buffer)
        return values
      end

      ##################################################################################
      def watch_file_spec(file_spec, watch_config)
        success = false
        root_dir = File.join(self.root, watch_config.watch_basedir, File::SEPARATOR)
        parts = file_spec.gsub(root_dir, "").split(File::SEPARATOR)

        non_blacklisted_paths = []
        buffer = root_dir
        parts.each do |part|
          buffer = File.join(buffer, part)
          if self.black_listed?(buffer)
            non_blacklisted_paths = []
            break
          else
            non_blacklisted_paths.push buffer
          end
        end

        clear_paths = {}
        non_blacklisted_paths.each do |path|
          path_watch_config = nil
          file_object = self.white_listed?(path)
          if file_object
            path_watch_config = file_object[:watch_config]
          else
            parent_file_object = self.find_file_object_parent(:white, path)
            if parent_file_object
              path_watch_config = parent_file_object[:watch_config]
            else
              path_watch_config = watch_config
            end
          end
          
          if path_watch_config.blank?
            clear_paths = {}
            break
          else
            if self.watchable?(path, path_watch_config)
              clear_paths[path] = path_watch_config
            else
              clear_paths = {}
              break
            end
          end

        end

        #if clear_paths.blank?
          #self.add_to_list(:black, file_spec, watch_config)
        #else
        unless clear_paths.blank?
          success = true
          clear_paths.each do |file_object|
            unless self.white_listed?(file_object.first)
              self.add_to_list(:white, file_object.first, file_object.last)
            end
          end
        end

        return success
      end

      ##################################################################################
      # ...
      def verify_parent_directory_nodes
        prisoners = []

        self.white_list.each do |file_object|
          root_dir = File.join(self.root, file_object.last[:watch_config].watch_basedir, File::SEPARATOR)
          sub_directory = file_object.first.gsub(root_dir, "").split(File::SEPARATOR)
          sub_directory.pop     # get rid of the current directory

          sub_directory.length.times do
            buffer = File.join(self.root, file_object.last[:watch_config].watch_basedir, sub_directory)

            if self.black_listed?(buffer) && !prisoners.include?(buffer)
              prisoners.push(buffer)
            end
            sub_directory.pop
          end
        end

        prisoners.each do |file_spec|
          self.white_list[file_spec] = self.black_list[file_spec]
          self.black_list.delete(file_spec)
        end

      end

      ##################################################################################
      # Determines if a directory or file is watchable based on a valid {WatchConfig} object.  watchable? evaluates file_spec against the included / excluded values
      # of {WatchConfig#filter_set WatchConfig#filter_set}.  Directories / files that pass all of the criteria are considered watchable and watchable?
      # will return true.
      #
      # {include:file:FILTERS.md}
      #
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @param [WatchConfig] config A valid {WatchConfig} object.
      # @return [Boolean] Returns true if it is watchable, otherwise, it returns false.
      def watchable?(file_spec, config)
        value = false

        # for directories / files the approach is pretty simple
        # - if excluded has been configured
        #     return true if NOT excluded via filter_set
        #
        # - else if included has been configured
        #     return true if included via filter_set
        #
        # - otherwise
        #     return true
        begin

          unless config.blank? || self.black_listed?(file_spec)

            ducklog.system "watchable? enter: #{file_spec}"
            if File.directory?(file_spec)

              # something to keep in mind here is i am factoring in the value of config.watch_basedir
              # it can make the difference of included_dirs / excluded_dirs passing or failing
              # depending on configuration.
              sub_directory = file_spec.gsub(File.expand_path(File.join(self.root, config.watch_basedir)), "")
              sub_directory = sub_directory =~ /^#{File::SEPARATOR}/ ? sub_directory.slice(1, sub_directory.length) : sub_directory
              base_name = File.basename(file_spec)

              unless base_name.eql?(".") || File.basename(file_spec).eql?("..")
                explicit_exclude = config.filter_set.has_excluded_dirs? ? config.filter_set.excluded_dirs?(file_spec, sub_directory) : false
                ducklog.system "    config.filter_set.has_excluded_dirs?  #{config.filter_set.has_excluded_dirs?} explicit_exclude? #{explicit_exclude}"

                unless explicit_exclude
                  if config.filter_set.has_included_dirs?
                    value = config.filter_set.included_dirs?(file_spec, sub_directory)
                    ducklog.system "    config.filter_set.has_included_dirs?  #{config.filter_set.has_included_dirs?} explicit_include? #{value}"

                  else
                    value = true
                    ducklog.system "    directory is ok to be included: #{value}"

                  end
                end

              end

            else

              # check if the current directory or any of the parent directories have been black listed.
              # if so, then, do not white list the file.
              dir_black_listed = false
              dir_name = File.dirname(file_spec).gsub(self.root, "")
              dir_name = dir_name.slice(1, dir_name.length) if dir_name =~ /^#{File::SEPARATOR}/
              dir_name = dir_name.split(File::SEPARATOR)

              dir_name.length.times do
                buffer = File.join(self.root, dir_name)
                if self.black_listed?(buffer)
                  ducklog.system "     dir_black_listed ==> #{buffer}"
                  dir_black_listed = true
                  break
                end
                dir_name.pop
              end

              unless dir_black_listed

                explicit_exclude = config.filter_set.has_excluded? ? config.filter_set.excluded?(file_spec) : false
                ducklog.system "    config.filter_set.has_excluded?  #{config.filter_set.has_excluded?} explicit_exclude? #{explicit_exclude}"

                unless explicit_exclude
                  if config.filter_set.has_included?
                    value = config.filter_set.included?(file_spec)
                    ducklog.system "    config.filter_set.included?  #{config.filter_set.has_included?} explicit_include? #{value}"

                  else
                    value = true
                    ducklog.system "    file_spec is ok to be included: #{value}"

                  end
                end

              end

            end

          else
            ducklog.console "config is empty or file already blacklisted: #{file_spec}"
          end

        rescue Exception => e
          ducklog.exception e
        end

        ducklog.system "    watchable? return: #{value}"

        return value
      end

      ##################################################################################
      # A simple Array of {WatchConfig WatchConfig} objects.
      # @return [Array]
      def watch_configs
        @watch_configs ||= []
        return @watch_configs
      end

      ##################################################################################
      # A list of file objects that have been whitelisted.  Files that are whitelisted
      # are considered to be a valid file and actionable.  A runnable test file is an
      # example of a file that is actionable.
      # @return [Hash]
      def white_list
        @white_list ||= {}
        return @white_list
      end

      ##################################################################################
      # Determines if a file object has been whitelisted.
      # @param [String] file_spec A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @return [Boolean] Returns true if the file has been whitelisted, otherwise, false.
      def white_listed?(file_spec)
        return self.white_list[file_spec]
      end

    end
  end
end
