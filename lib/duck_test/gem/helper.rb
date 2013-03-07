# once upon a time, I had a series of tasks and gemspecs to build different versions for different platforms.
# I made a decision to adandon all of those different gems and simply notify the developer to edit their Gemfile.
# however, i kept this code in case i need to go back down that path...
require "yaml"

module DuckTest
  # ...
  module Gem

    ##################################################################################
    # ...
    class Helper

      ##################################################################################
      # ...
      def initialize
        super
      end

      ##################################################################################
      # ...
      def base_dir
        @base_dir ||= File.expand_path(".")
        return @base_dir
      end

      # ...
      def base_dir=(value)
        @base_dir = File.expand_path(value)
      end

      ##################################################################################
      # ...
      def output_gem_spec(name, pkg = "")
        Dir[File.join(self.base_dir, pkg, "#{name}*.gem")].sort_by{|f| File.mtime(f)}.last
      end

      ##################################################################################
      # ...
      def build(gem_spec, output_gem_spec)
        %x(gem build -V '#{gem_spec}.gemspec')
        output_file_spec = self.output_gem_spec(output_gem_spec)
        file_name = File.basename(output_file_spec)
        FileUtils.mkdir_p(File.join(self.base_dir, 'pkg'))
        FileUtils.mv(output_file_spec, 'pkg')
        puts "#{file_name} built to pkg/#{file_name}"
      end

      ##################################################################################
      # ...
      def install(gem_spec, output_gem_spec)
        self.build(gem_spec, output_gem_spec)
        output_file_spec = self.output_gem_spec(output_gem_spec, "pkg")
        puts "Installing gem: #{output_file_spec}"
        %x(gem install '#{output_file_spec}')
        puts "   Install complete."
      end

      ##################################################################################
      # ...
      def release(gem_spec, output_gem_spec)
        if File.exist?(File.expand_path("~/.gem/credentials"))
          self.build(gem_spec, output_gem_spec)
          output_file_spec = self.output_gem_spec(output_gem_spec, "pkg")
          puts "Releasing gem: #{output_file_spec}"
          %x(gem push '#{output_file_spec}')
          puts "   Release complete."
        else
          raise "Your rubygems.org credentials aren't set. Run `gem push` to set them."
        end
      end

      ##################################################################################
      # ...
      def local(gem_spec, output_gem_spec)
        config_file_spec = File.expand_path("~/.gem/gemserverlocal")

        if File.exist?(config_file_spec)

          yaml = YAML.load_file(config_file_spec)

          if yaml && yaml["path"]

            path = yaml["path"]

            self.build(gem_spec, output_gem_spec)
            output_file_spec = self.output_gem_spec(output_gem_spec, 'pkg')

            puts "Locally releasing gem: #{output_file_spec}"
            FileUtils.mkdir_p(File.join(path, 'gems'))
            FileUtils.cp(output_file_spec, File.join(path, 'gems'))

            %x(gem generate_index --directory #{path})
            puts "   Local release complete."

          else
            raise "~/.gem/gemserverlocal file exists, however, path: /path/to/repo is missing.  please add a path to the root of a local gem server"
          end
        else
          raise "~/.gem/gemserverlocal file is missing.  Please create the file and include path: /path/to/repo to the root of a local gem server"
        end
      end

    end

  end
end
