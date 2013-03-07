module DuckTest
  module FrameWork
    module TestUnit

      ##################################################################################
      # FrameWork for running Test::Unit tests
      class FrameWork < DuckTest::FrameWork::Base

        ##################################################################################
        # Does the work of actually running the tests.
        def run_tests

          if defined?(::Test::Unit::Runner)
            ducklog.console "Running tests using: Test::Unit::Runner"
            ::Test::Unit::Runner.new.run([])

          elsif defined?(::MiniTest::Unit)
            ducklog.console "Running tests using: MiniTest::Unit"
            ::MiniTest::Unit.new.run([])

          else
            ducklog.console "Cannot run tests.  Unable to determine which test runner to use."

          end

          print ::IRB.CurrentContext.io.prompt

        end

      end
    end
  end
end
