require 'test_helper'

##################################################################################
class BuildWatchListsTestObject
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

class BuildWatchListsTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = BuildWatchListsTestObject.new
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  ##################################################################################
  test "should find all of the test directories / files" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*"))
    @test_object.build_watch_lists

    file_list = TestFiles.file_list
    dir_list = TestFiles.dir_list
    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    dir_list.each do |dir_spec|
      assert @test_object.white_listed?(dir_spec), "#{dir_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first) || dir_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  ##################################################################################
  test "should whitelist all files by default" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*"))
    @test_object.build_watch_lists

    file_list = TestFiles.dir("**/*")
    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  ##################################################################################
  test "should whitelist all spec files by default" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test))
    @test_object.build_watch_lists

    file_list = TestFiles.dir("test/**/*")
    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  ##################################################################################
  test "should whitelist all app files by default" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :app))
    @test_object.build_watch_lists

    file_list = TestFiles.dir("app/**/*")
    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  ##################################################################################
  test "should whitelist all spec bike files" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test, included: /^bike/))
    @test_object.build_watch_lists

    file_list = TestFiles.dir(["test/**/bike*", "test/unit", "test/functional", "test/fixtures", "test/integration", "test/performance", "test/unit/sec", "test/unit/admin"])
    file_list.each do |file_spec|
      assert !@test_object.black_listed?(file_spec), "#{file_spec} should not have been blacklisted"
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  ##################################################################################
  test "should whitelist all spec files except bike" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test, excluded: /^bike/))
    @test_object.build_watch_lists

    file_list = TestFiles.dir(["test/**/bike*"])
    file_list.each do |file_spec|
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been blacklisted"
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been whitelisted"
    end

  end

  ##################################################################################
  test "should whitelist all spec bike files 2" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test, included_dirs: /unit/))
    @test_object.build_watch_lists

    file_list = TestFiles.dir("test/unit")
    file_list.each do |file_spec|
      assert !@test_object.black_listed?(file_spec), "#{file_spec} should not have been blacklisted"
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

  end

  ##################################################################################
  test "should whitelist all spec files except bike 2" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test, excluded_dirs: /unit/))
    @test_object.build_watch_lists

    file_list = TestFiles.dir("test/unit")
    file_list.each do |file_spec|
      assert @test_object.black_listed?(file_spec), "#{file_spec} should not have been blacklisted"
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

  end

  ##################################################################################
  test "should whitelist all spec files and make them runnable and all app files and make them non-runnable" do
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :test, runnable: true))
    @test_object.watch_configs.push(DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", watch_basedir: :app))
    @test_object.build_watch_lists

    runnable_root = File.join(@test_object.root, "test")
    watch_root = File.join(@test_object.root, "app")

    @test_object.white_list.each do |file_object|
      if file_object.first =~ /^#{runnable_root}/
        assert file_object.last[:watch_config].runnable?, "#{file_object.first} should be runnable"

      elsif file_object.first =~ /^#{watch_root}/
        assert !file_object.last[:watch_config].runnable?, "#{file_object.first} should be non-runnable"

      else
        assert false, "should not have made it here"

      end
    end

  end

end
