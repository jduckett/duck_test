module DuckTest

  # Provides usage details for all of the console commands.
  module Usage

    ##################################################################################
    # @note future version will pull usage info using i18n
    # @param [Symbol] key       The usage details to display.
    # @param [Boolean] show     Flag indicating if the details should be displayed.
    #                           This value is often used by the calling code as part of an unless statement.
    # @return [Boolean] Returns the value of show
    def usage(key, show = false)

      if show
        content = YAML.load_file(File.expand_path(__FILE__).gsub(".rb", ".yml"))
        case key
        when :usage
          puts "DuckTest #{VERSION}"
          puts content[:usage]

        else
          if content[key]
            puts content[key]
          else
            puts "help not found for command: #{key}"
          end
        end
      end

      return show
    end

  end
end
