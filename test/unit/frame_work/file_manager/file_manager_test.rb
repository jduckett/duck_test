require 'test_helper'

##################################################################################
class FileManagerTestObject < DuckTest::FrameWork::Base
  include DuckTest::FrameWork::FileManager

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

class FileManagerTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = FileManagerTestObject.new("file_manager_spec")
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  ##################################################################################
  test "should have default values" do
    assert @test_object.black_list.kind_of?(Hash) && @test_object.black_list.blank?, "black_list default should an empty Hash"
    assert @test_object.watch_configs.kind_of?(Array) && @test_object.watch_configs.blank?, "watch_configs default should an empty Hash"
    assert @test_object.white_list.kind_of?(Hash) && @test_object.white_list.blank?, "white_list default should an empty Hash"
    assert @test_object.listener.blank?, "listener default should be blank"
    assert @test_object.queue.blank?, "queue default should be blank"
  end

  ##################################################################################
  test "should add a file object to black list" do
    file_spec = TestFiles.file_list.first
    watch_config = DuckTest::FrameWork::WatchConfig.new
    @test_object.add_to_list(:black, file_spec, watch_config)
    assert @test_object.black_listed?(file_spec), "#{file_spec} should have been blacklisted"
  end

  ##################################################################################
  test "should add a file object to white list" do
    file_spec = TestFiles.file_list.first
    watch_config = DuckTest::FrameWork::WatchConfig.new
    @test_object.add_to_list(:white, file_spec, watch_config)
    assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
  end

  ##################################################################################
  test "should add a file object to black list unless it exists on disk" do
    file_spec = "#{TestFiles.file_list.first}.tmp"
    watch_config = DuckTest::FrameWork::WatchConfig.new
    @test_object.add_to_list(:black, file_spec, watch_config)
    assert !@test_object.black_listed?(file_spec), "#{file_spec} should have been blacklisted"
  end

  ##################################################################################
  test "should add a file object to white list unless it exists on disk" do
    file_spec = "#{TestFiles.file_list.first}.tmp"
    watch_config = DuckTest::FrameWork::WatchConfig.new
    @test_object.add_to_list(:white, file_spec, watch_config)
    assert !@test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
  end

end
