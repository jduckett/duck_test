module DuckTest
  module FrameWork
    module RSpec

      # Testing Framework for RSpec
      class FrameWork < DuckTest::FrameWork::Base

        ##################################################################################
        # This is a hack to override run_fork in order to set the rspec global variable rspec_start_time.
        # The report at the end of the run of the specs was reporting incorrect duration since rspec_start_time
        # is set when the gem loads.  This is a good place to start looking if incorrect results start happenning again.
        def run_fork(non_runnable_files, runnable_files, force_run = false)
          $rspec_start_time = Time.now
          super(non_runnable_files, runnable_files, force_run)
        end

        ##################################################################################
        # Does the work of actually running the tests.
        def run_tests

          ::RSpec::Core::Runner.run([])

          print ::IRB.CurrentContext.io.prompt

        end

      end
    end
  end
end
