module DuckTest
  module FrameWork

    # Queue is responsible to managing and triggering events after being notified via a listener.
    class Queue
      include DuckTest::ConfigHelper
      include LoggerHelper

      # Boolean flag used to force the queue to empty and run any pending regardless of the current state of autorun.
      attr_accessor :force_run

      # Holds the time when a queue event was last triggered.  This value is a factor when calculating if the queue should be processed.
      attr_accessor :last_queue_event

      # Latency is the amount of time that should pass between each time the event queue is processed.  The default value is: 0.15, however,
      # you can use any valid float number.  Use this value in conjuction with {#speed} to fine tune the overall behavior of the queue.
      #
      #   set_latency(10)    # wait 10 seconds since the last time the queue event was triggered.  Regardless of the setting of {#speed}.
      #
      attr_accessor :latency

      # A {http://ruby-doc.org/core-1.9.3/Mutex.html Mutex} used when working on data items related specifically to the Queue.
      attr_accessor :lock

      # A boolean flag used to determine if it is ok to process and run the set of tests currently in the queue.
      # Depending on settings and the number of tests being run, the queue loop may need to wait for the queue_event_block to complete it's previous run.
      # This flag helps control that situation.
      attr_accessor :ok_to_run

      # An Array representing the list of files that have changed and need to be processed.
      attr_accessor :queue

      # The block to execute when after the queue has been processed and a list of runnable test files is ready to be run.
      attr_accessor :queue_event_block

      # A {http://ruby-doc.org/core-1.9.3/Mutex.html Mutex} used when working on data items related specifically executing the queue event.
      attr_accessor :queue_event_lock

      # A float number indicating how fast the queue should run.  The thread processing the queue will sleep for the value set by speed.
      # The default value is 0.15, however, you can use any valid float number.  Use this value in conjuction with {#latency} to fine tune the overall behavior of the queue.
      # The higher the number, the slower the speed since the thread containing the loop that checks the queue uses speed as the time to sleep between each interation of the loop.
      #
      #   set_speed(5)    # sleep 5 seconds between each interation of the loop.
      #
      attr_accessor :speed

      # A boolean indicating if the queue should stop processing and have the thread end it's loop.
      attr_accessor :stop

      # A reference to the thread object responsible for processing the queue.
      attr_accessor :thread

      # A running total of the total number of files that have been processed by the queue during the lifetime of a Queue session.
      attr_accessor :total_ran

      alias :force_run? :force_run
      alias :ok_to_run? :ok_to_run
      alias :stop? :stop

      ##################################################################################
      def initialize

        super

        self.force_run = false
        self.last_queue_event = Time.now
        self.latency = 0.65
        self.lock = Mutex.new
        self.queue = []
        self.queue_event_block = nil
        self.queue_event_lock = Mutex.new
        self.speed = 0.65 #25
        self.stop = false
        self.total_ran = 0

      end

      ##################################################################################
      # Sets the block to execute when the queue has runnable test files ready to be run.
      # The value of this block is actually set by {FileManager}.
      # @return [NilClass]
      def queue_event(&block)
        if block_given?
          self.queue_event_block = block
          self.ok_to_run = true
        end

        return nil
      end

      ##################################################################################
      # Executes {#queue_event_block} and passes the list of runnable test files to it.
      # A thread lock is obtained and {#ok_to_run} is set to false prior to executing the block.
      # {#ok_to_run} is set back to true after the block completes execution.
      # @param [Array] list A list of full file specs pointing to runnable test files.
      # @return [NilClass]
      def run(list = [])

        self.queue_event_lock.synchronize do

          self.ok_to_run = false

          unless self.queue_event_block.blank?
            self.queue_event_block.call QueueEvent.new(self, list)
          end

          self.ok_to_run = true

        end

        return nil
      end

      ##################################################################################
      # Starts the queue thread which is the controlling body of the Queue class.
      # @return [NilClass]
      def start

        self.thread = Thread.new do

          begin

            until self.stop do

              sleep(self.speed)

              if self.autorun? || self.force_run?
                if self.ok_to_run?
                  buffer = []
                  self.lock.synchronize do
                    self.force_run = false
                    if ((Time.now - self.last_queue_event) >= self.latency)
                      length = self.queue.length
                      length.times {|x| buffer.push(self.queue.pop)}
                      self.total_ran += buffer.length
                    end
                  end

                  if (buffer.length > 0)
                    self.run(buffer)
                  end
                else
                  ducklog.console "Waiting on runner.  Files in queue: (#{self.queue.length})  Total ran during session: (#{self.total_ran})"
                end
              end

            end

          rescue Exception => e
            ducklog.exception e
          end

        end

        return nil
      end

      ##################################################################################
      # Adds a file_spec to the list of runnable test files that need to be run.  It prevents duplicates by
      # checking to see if the file_spec is already in the queue.
      # @param [String] file_spec The full file specification of the file or directory on which the event occured.
      # @return [NilClass]
      def push(file_spec)

        self.lock.synchronize do

          if self.autorun? && !self.queue.include?(file_spec)
            self.queue.push(file_spec)
          end

          self.last_queue_event = Time.now

        end

        return nil
      end

      ##################################################################################
      # Safely resets the queue to an empty Array.
      # @return [NilClass]
      def reset
        self.lock.synchronize do
          self.queue = []
        end
        return nil
      end

      ##################################################################################
      # Safely sets the value of {#speed}
      # @return [NilClass]
      def set_speed(value)
        self.lock.synchronize do
          self.speed = value unless value.blank?
        end
        return nil
      end

      ##################################################################################
      # Safely sets the value of {#latency}
      # @return [NilClass]
      def set_latency(value)
        self.lock.synchronize do
          self.latency = value unless value.blank?
        end
        return nil
      end

      ##################################################################################
      # Returns the total number of tests in the queue waiting to run.
      # @return [Number]
      def tests_pending
        value = 0
        self.lock.synchronize do
          value = self.queue.length
        end
        return value
      end

    end
  end
end
