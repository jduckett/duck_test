require 'test_helper'

##################################################################################
class MapTestObject
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

class MapTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    DuckTest::Config.reset
    @test_object = MapTestObject.new
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  #################################################################################
  test "should map to specific files" do

    DuckTest.config do

      runnable_basedir :test

      runnable "**/*"

      watch "**/*", /^bike/ do
        map /^models/, /^bike/ do
          target /^unit/, /bike_test/
          target /^functional/, /bike_controller/
        end
      end

    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    @test_object.build_watch_lists

    assert @test_object.white_list.length > 0, "should have found some files"

    file_spec = TestFiles.file_spec("bike")
    file_list = [TestFiles.file_spec("bike_test"), TestFiles.file_spec("bike_controller_test")]
    watch_config = @test_object.white_list[file_spec][:watch_config]
    runnable_files = @test_object.find_runnable_files(file_spec, watch_config)

    file_list.each do |file_spec|
      assert runnable_files.include?(file_spec), "#{file_spec} should have been found"
    end

    runnable_files.each do |file_spec|
      assert file_list.include?(file_spec), "#{file_spec} should have been found"
    end

  end

  #################################################################################
  test "should map to specific files 2" do

    DuckTest.config do

      runnable_basedir :test

      runnable "**/*"

      watch "**/*", /^bike/ do
        map do
          target :all do
            file_name {|value, cargo| value =~ /#{File.basename(cargo, ".rb")}_test.rb/ || value =~ /#{File.basename(cargo, ".rb")}_controller_test.rb/}
          end
        end
      end

    end

    DuckTest::Config.get_framework(:testunit)[:watch_configs].each do |watch_config|
      @test_object.watch_configs.push(watch_config)
    end

    @test_object.build_watch_lists

    file_spec = TestFiles.file_spec("bike")
    file_list = [TestFiles.file_spec("bike_test"), TestFiles.file_spec("bike_controller_test")]
    watch_config = @test_object.white_list[file_spec][:watch_config]
    runnable_files = @test_object.find_runnable_files(file_spec, watch_config)

    file_list.each do |file_spec|
      assert runnable_files.include?(file_spec), "#{file_spec} should have been found"
    end

  end

end
