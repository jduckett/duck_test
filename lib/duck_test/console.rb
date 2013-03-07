module DuckTest

  # Module to include in the standard IRB class to provide a reference to DuckTest {Commands commands}.
  module Console
    include DuckTest::LoggerHelper

    ##################################################################################
    # Returns an instance of {Commands} class to allow a user to perform tasks like the following directly in the Rails console.
    #
    #   duck.speed 1            # sets the queue speed
    #   duck.latency 2          # sets the queue latency
    #
    def duck
      return DuckTest::Commands.new
    end

  end
end
