require 'test_helper'

##################################################################################
class WatchTestObject
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

class WatchTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    DuckTest::Config.reset
    @test_object = WatchTestObject.new
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  #################################################################################
  test "should find all runnable files" do

    DuckTest.config do
      runnable_basedir :test
      runnable "**/*"
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :test}, pattern: :all, path: :full)
    file_list.concat(TestFiles.find_dirs(dir: :test, path: :full))
    file_list.sort!
    file_list.shift   # TestFiles always returns the root and we don't need it, so, nuke it.

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first) || dir_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  #################################################################################
  test "should find all non-runnable files" do

    DuckTest.config do
      watch "**/*"
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)
    file_list.concat(TestFiles.find_dirs(dir: :app, path: :full))
    file_list.sort!
    file_list.shift   # TestFiles always returns the root and we don't need it, so, nuke it.

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
    end

    @test_object.white_list.each do |file_object|
      assert file_list.include?(file_object.first) || dir_list.include?(file_object.first), "#{file_object.first} was not found in the list of test directories / files"
    end

  end

  #################################################################################
  test "should find files using multiple patterns" do

    DuckTest.config do
      watch ["**/bike*", "**/truck*"]
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    @test_object.white_list.each do |file_object|
      unless File.directory?(file_object.first)
        assert file_object.first.include?("truck") || file_object.first.include?("bike"),"#{file_object.first} was not found in the list of test directories / files"
      end
    end

  end

end
