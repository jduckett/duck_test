require 'test_helper'

class QueueTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = DuckTest::FrameWork::Queue.new
    
    # orignal tests did not include this line here.  however, after changing the queue class i needed to add it
    @test_object.autorun = true
  end

  ##################################################################################
  test "last_queue_event should NOT be blank by default" do
    assert !@test_object.last_queue_event.blank?, "expected value: A time stamp value   actual value: #{@test_object.last_queue_event}"
  end

  ##################################################################################
  test "latency should NOT be blank by default" do
    assert !@test_object.latency.blank?, "expected value: 0.15 or a valid float number   actual value: #{@test_object.latency}"
  end

  ##################################################################################
  test "lock should NOT be blank by default" do
    assert @test_object.lock.kind_of?(Mutex), "expected value: Mutex actual value: #{@test_object.lock}"
  end

  ##################################################################################
  test "ok_to_run should be blank by default" do
    assert @test_object.ok_to_run.kind_of?(NilClass), "expected value: NilClass actual value: #{@test_object.ok_to_run}"
  end

  ##################################################################################
  test "ok_to_run should be set to true after the queue event block is set" do
    assert @test_object.ok_to_run.kind_of?(NilClass), "expected value: NilClass actual value: #{@test_object.ok_to_run}"
    @test_object.queue_event {|| x = 1}
    assert @test_object.ok_to_run.kind_of?(TrueClass), "expected value: TrueClass actual value: #{@test_object.ok_to_run.class.name}"
    assert @test_object.ok_to_run?, "expected value: true actual value: #{@test_object.ok_to_run?}"
  end

  ##################################################################################
  test "queue should be an empty Array by default" do
    assert @test_object.queue.kind_of?(Array), "expected value: Array actual value: #{@test_object.queue.class.name}"
    assert @test_object.queue.blank?, "expected value: [] actual value: #{@test_object.queue}"
  end

  ##################################################################################
  test "queue_event_block should be blank by default" do
    assert @test_object.queue_event_block.kind_of?(NilClass), "expected value: NilClass actual value: #{@test_object.queue_event_block}"
  end

  ##################################################################################
  test "queue_event_lock should NOT be blank by default" do
    assert @test_object.queue_event_lock.kind_of?(Mutex), "expected value: Mutex actual value: #{@test_object.queue_event_lock}"
  end

  ##################################################################################
  test "speed should NOT be blank by default" do
    assert !@test_object.speed.blank?, "expected value: 0.15 or a valid float number   actual value: #{@test_object.speed}"
  end

  ##################################################################################
  test "stop should be set to true after the queue event block is set" do
    assert @test_object.stop.kind_of?(FalseClass), "expected value: FalseClass actual value: #{@test_object.stop.class.name}"
    assert !@test_object.stop, "expected value: false actual value: #{@test_object.stop}"
    assert !@test_object.stop?, "expected value: false actual value: #{@test_object.stop?}"
    @test_object.stop = true
    assert @test_object.stop, "expected value: true actual value: #{@test_object.stop}"
    assert @test_object.stop?, "expected value: true actual value: #{@test_object.stop?}"
  end

  ##################################################################################
  test "total_ran should NOT be blank by default" do
    assert !@test_object.total_ran.blank?, "expected value: 0.15 or a valid float number   actual value: #{@test_object.total_ran}"
  end

  ##################################################################################
  test "should push files onto the queue" do
    # should be full file specs, however, should be ok for this test.
    @test_object.push("test01.rb")
    @test_object.push("test02.rb")
    @test_object.push("test03.rb")
    @test_object.push("test04.rb")
    assert @test_object.queue.length == 4, "expected value: 4 actual value: #{@test_object.queue.length}"
  end

  ##################################################################################
  test "should NOT push files onto the queue that are already on the queue" do
    # should be full file specs, however, should be ok for this test.
    @test_object.push("test01.rb")
    @test_object.push("test01.rb")
    @test_object.push("test01.rb")
    @test_object.push("test01.rb")

    @test_object.push("test02.rb")
    @test_object.push("test03.rb")
    @test_object.push("test04.rb")
    assert @test_object.queue.length == 4, "expected value: 4 actual value: #{@test_object.queue.length}"
  end

  ##################################################################################
  test "should safely set the queue speed" do
    @test_object.set_speed(2)
    assert @test_object.speed.eql?(2), "expected value: 2 actual value: #{@test_object.speed}"
  end

  ##################################################################################
  test "should safely set the queue latency" do
    @test_object.set_latency(4)
    assert @test_object.latency.eql?(4), "expected value: 4 actual value: #{@test_object.latency}"
  end

end
