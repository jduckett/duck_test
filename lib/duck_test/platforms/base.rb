module DuckTest
  # ...
  module Platforms

    autoload :Generic, 'duck_test/platforms/generic/base'
    autoload :Linux, 'duck_test/platforms/linux/base'
    autoload :Listener, 'duck_test/platforms/listener'
    autoload :Mac, 'duck_test/platforms/mac/base'
    autoload :OSHelper, 'duck_test/platforms/os_helper'
    autoload :WatchEvent, 'duck_test/platforms/watch_event'
    autoload :Windows, 'duck_test/platforms/windows/base'

    # ...
    module Base
    end

  end
end
