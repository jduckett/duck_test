require 'test_helper'

##################################################################################
class FilterTestObject
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

class FilterTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    DuckTest::Config.reset
    @test_object = FilterTestObject.new
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  #################################################################################
  test "should only return bike stuff" do

    DuckTest.config do
      watch "**/*", /^bike/
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: /^bike/, path: :full)
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

  #################################################################################
  test "should include files for multiple expressions" do

    DuckTest.config do
      watch "**/*", [/^bike/, /^car/, /^truck/]
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: /^bike/, path: :full)
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^car/, path: :full))
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^truck/, path: :full))
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

  #################################################################################
  test "should include files for multiple expressions excluding directories /controllers" do

    DuckTest.config do
      watch "**/*", [/^bike/, /^car/, /^truck/], excluded_dirs: /controllers/
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: /^bike/, path: :full)
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^car/, path: :full))
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^truck/, path: :full))
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    file_list.delete(TestFiles.file_spec("bike_controller"))
    file_list.delete(TestFiles.file_spec("car_controller"))
    file_list.delete(TestFiles.file_spec("truck_controller"))

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

  #################################################################################
  test "should include files for multiple expressions excluding files that have controller in the name" do

    DuckTest.config do
      watch "**/*", [/^bike/, /^car/, /^truck/], excluded: /controller/
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: /^bike/, path: :full)
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^car/, path: :full))
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^truck/, path: :full))
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    file_list.delete(TestFiles.file_spec("bike_controller"))
    file_list.delete(TestFiles.file_spec("car_controller"))
    file_list.delete(TestFiles.file_spec("truck_controller"))

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

  #################################################################################
  test "should include files for multiple explicitly included expressions excluding files that have controller in the name" do

    DuckTest.config do
      watch "**/*", included: [/^bike/, /^car/, /^truck/], excluded: /controller/
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = TestFiles.find_files(dirs: {dir: :app}, pattern: /^bike/, path: :full)
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^car/, path: :full))
    file_list.concat(TestFiles.find_files(dirs: {dir: :app}, pattern: /^truck/, path: :full))
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    file_list.delete(TestFiles.file_spec("bike_controller"))
    file_list.delete(TestFiles.file_spec("car_controller"))
    file_list.delete(TestFiles.file_spec("truck_controller"))

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

  #################################################################################
  test "should include files for multiple explicitly included expressions excluding files that have controller in the name 2" do

    DuckTest.config do
      watch "**/*", included: [/^bike/, /^car/, /^truck/], included_dirs: /controllers/
    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    file_list = []
    file_list.push(TestFiles.file_spec("bike_controller"))
    file_list.push(TestFiles.file_spec("car_controller"))
    file_list.push(TestFiles.file_spec("truck_controller"))
    all_list = TestFiles.find_files(dirs: {dir: :app}, pattern: :all, path: :full)

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_list.each do |file_spec|
      assert @test_object.white_listed?(file_spec), "#{file_spec} should have been whitelisted"
      all_list.delete(file_spec)
    end

    all_list.each do |file_spec|
      assert !@test_object.white_listed?(file_spec), "#{file_spec} should not have been on the white list"
      assert @test_object.black_listed?(file_spec), "#{file_spec} should have been on the black list"
    end

  end

end
