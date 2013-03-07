require 'test_helper'

##################################################################################
class QueueEventTestObject < DuckTest::FrameWork::Base
  include DuckTest::FrameWork::FileManager

  ##################################################################################
  def load_files_from_disk(event)
  end

  ##################################################################################
  def clear_tests
  end

  ##################################################################################
  def run_tests
  end

  # methods added to object for testing only
  ##################################################################################
  def reset_white_list
    @white_list = {}
    return @white_list
  end

  ##################################################################################
  def white_list_delete(file_spec)
    @white_list.delete(file_spec)
    return @white_list
  end

end

class QueueEventTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = QueueEventTestObject.new("queue_event_test")

    # orignal tests did not include this line here.  however, after changing the queue class i needed to add it
    @test_object.autorun = true
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  #test "should not queue a file that has been blacklisted" do

    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/truck_test.rb", excluded: /truck_test/))
    #@test_object.build_watch_lists
    #file_spec = TestFiles.file_spec("truck_test.rb")

    #assert @test_object.black_listed?(file_spec), "#{file_spec} should have been blacklisted"

    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))
    #assert list.blank?, "list should be empty"

  #end

  #it "should not queue a file that is a directory even if it is runnable" do

    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", runnable: true))
    #@test_object.build_watch_lists
    #file_spec = TestFiles.file_spec("truck_spec.rb")
    #dir_name = File.dirname(TestFiles.file_spec("truck_spec.rb"))

    #assert !@test_object.black_listed?(file_spec), "#{file_spec} should NOT have been blacklisted"
    #assert !@test_object.black_listed?(dir_name), "#{dir_name} should NOT have been blacklisted"

    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [dir_name]))
    #assert list.blank?, "list should be empty"

  #end

  #it "should run a file if it is a file, not a directory, and is flagged as runnable" do

    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/truck_spec.rb", runnable: true))
    #@test_object.build_watch_lists
    #file_spec = TestFiles.file_spec("truck_spec.rb")

    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))
    #assert list.length == 1, "should have a length of one"
    #assert list.first.eql?(file_spec), "first file in list should have matched #{file_spec}"

  #end

  #it "should find a runnable file based on the config of a non-runnable file" do

    ## simulate a configuration
    #watch_config = DuckTest::FrameWork::WatchConfig.new(pattern: "**/truck.rb", runnable: false, watch_basedir: :app)

    #map = Map.new(sub_directory: /^models/, file_name: /[a-z]/, watch_basedir: "app") do
      #target sub_directory: /^unit/, file_name: /[a-z]_spec.rb/, watch_basedir: "spec"
      #target sub_directory: /^functional/, file_name: /[a-z]_controller_spec.rb/, watch_basedir: "spec"
    #end

    #watch_config.maps.push(map)

    ## add config for non-runnable
    #@test_object.watch_configs.push(watch_config)

    ## add another for runnable
    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/truck_spec.rb", runnable: true))

    ## build black / white lists
    #@test_object.build_watch_lists

    #file_spec = TestFiles.file_spec("truck.rb")
    #target_file_spec = TestFiles.file_spec("truck_spec.rb")

    ## try to queue file_spec should actually find the target_file_spec and queue it up.
    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))
    #assert list.length == 1, "should have a length of one"
    #assert list.first.eql?(target_file_spec), "first file in list should have matched #{target_file_spec}"

  #end

  ###################################################################################
  #it "should simulate a file change to a non-runnable file that is mapped to a set of runnable files" do

    ## simulate a configuration
    #watch_config = DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", runnable: false, watch_basedir: :app)

    #map = Map.new(sub_directory: /^models/, file_name: /bike/, watch_basedir: "app") do
      #target sub_directory: /^unit/, file_name: /bike_spec.rb/, watch_basedir: "spec"
      #target sub_directory: /^functional/, file_name: /bike_controller_spec.rb/, watch_basedir: "spec"
    #end

    #watch_config.maps.push(map)

    ## add config for non-runnable
    #@test_object.watch_configs.push(watch_config)

    ## add another for runnable
    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :spec, runnable: true))

    ## build black / white lists
    #@test_object.build_watch_lists

    #file_spec = File.join(@test_object.root, "app", "models", "bike.rb")
    #target_file_specs = [TestFiles.file_spec("bike_spec.rb"), TestFiles.file_spec("bike_controller_spec.rb")]

    ## try to queue file_spec should actually find the target_file_spec and queue it up.
    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))

    #assert list.length == 2, "should have a length of two"
    #target_file_specs.each do |target_file_spec|
      #assert list.include?(target_file_spec), "list should have included: #{target_file_spec}"
    #end

  #end

  ###################################################################################
  #it "should simulate a file change to a non-runnable file that is mapped to all runnable files in a sub_directory" do

    ## simulate a configuration
    #watch_config = DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", runnable: false, watch_basedir: :app)

    #map = Map.new(sub_directory: /^models/, file_name: /[a-z]/, watch_basedir: "app") do
      #target sub_directory: /^unit/, file_name: /[a-z]_spec.rb/, watch_basedir: "spec"
      #target sub_directory: /^functional/, file_name: /[a-z]_controller_spec.rb/, watch_basedir: "spec"
    #end

    #watch_config.maps.push(map)

    ## add config for non-runnable
    #@test_object.watch_configs.push(watch_config)

    ## add another for runnable
    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :spec, runnable: true))

    ## build black / white lists
    #@test_object.build_watch_lists

    #file_spec = File.join(@test_object.root, "app", "models", "bike.rb")
    #target_file_specs = TestFiles.spec_files(dirs: {pattern: [/^unit/, /^func/]}, path: :full)

    ## try to queue file_spec should actually find the target_file_spec and queue it up.
    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))

    #assert list.length == target_file_specs.length, "list.length #{list.length} should have been: #{target_file_specs.length}"
    #target_file_specs.each do |target_file_spec|
      #assert list.include?(target_file_spec), "list should have included: #{target_file_spec}"
    #end

  #end

  ###################################################################################
  ## meaning, if bike.rb model changes, it runs bike_spec.rb and bike_controller_spec.rb
  #it "should simulate a file change to a non-runnable file that is mapped to it's relative runnable files" do

    ## simulate a configuration
    #watch_config = DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", runnable: false, watch_basedir: :app)

    #map = Map.new(sub_directory: /^models/, file_name: /[a-z]/, watch_basedir: "app") do
      ## x is the value being processed (sub_directory or file_name)  in this case, file_name
      ## y is the source_file_spec.  in this example it is bike.rb
      ## extracts "bike" from y to create z
      ## uses z to determine if the file should pass evaluation.
      #target sub_directory: /^unit/, file_name: Proc.new {|x, y| z = y.slice(0, y.index('.')); !x.match(/^#{z}/).blank?;}, watch_basedir: "spec"
      #target sub_directory: /^functional/, file_name: Proc.new {|x, y| z = y.slice(0, y.index('.')); !x.match(/^#{z}/).blank?;}, watch_basedir: "spec"
    #end

    #watch_config.maps.push(map)

    ## add config for non-runnable
    #@test_object.watch_configs.push(watch_config)

    ## add another for runnable
    #@test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :spec, runnable: true))

    ## build black / white lists
    #@test_object.build_watch_lists

    #file_spec = File.join(@test_object.root, "app", "models", "bike.rb")
    #target_file_specs = [TestFiles.file_spec("bike_spec.rb"), TestFiles.file_spec("bike_controller_spec.rb")]

    ## try to queue file_spec should actually find the target_file_spec and queue it up.
    #list = @test_object.queue_event(DuckTest::FrameWork::QueueEvent.new(self, [file_spec]))
    #assert list.length == target_file_specs.length, "#{list.length} should have a length of #{target_file_specs.length}"
    #target_file_specs.each do |target_file_spec|
      #assert list.include?(target_file_spec), "list should have included: #{target_file_spec}"
    #end

  #end

end










