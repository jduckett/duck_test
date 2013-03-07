module DuckTest

  class DefaultConfig

    ##################################################################################
    # Runs a default configuration for a target testing framework.
    def self.config(target)

      puts "Autoloading configuration for framework: #{target}"
      case target
      when :testunit

        DuckTest.config do
          excluded [/.gitkeep$/, /kate-swp$/, /.yml$/, /test_helper/, /^.goutputstream/]
          excluded_dirs [/^assets/, /^fixtures/]

          watch_basedir :app

          runnable "**/*"
          watch "**/*" do
            standard_maps
          end
        end

      when :rspec

        DuckTest.config do

          excluded [/.gitkeep$/, /kate-swp$/, /.yml$/, /spec_helper/, /^.goutputstream/]
          excluded_dirs [/^assets/, /^fixtures/]

          runnable_basedir :spec
          watch_basedir :app

          runnable "**/*"
          watch "**/*" do
            standard_maps
          end

        end

      end

    end

  end

end
