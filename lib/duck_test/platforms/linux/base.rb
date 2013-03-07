module DuckTest
  # ...
  module Platforms
    # ...
    module Linux

      autoload :Listener, 'duck_test/platforms/linux/listener'

      # ...
      module Base
      end

    end
  end
end
