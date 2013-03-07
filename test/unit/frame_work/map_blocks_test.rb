require 'test_helper'

class MapBlocksTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = DuckTest::FrameWork::Map.new
  end

  ##################################################################################
  test "test mapping 001" do

    map = DuckTest::FrameWork::Map.new /^models/, /^bike/, watch_basedir: :app, runnable_basedir: :test do

      target /^unit/, /^bike_test.rb/
      target /^functional/, /^bike_controller_test.rb/

    end

    watch_file_spec = TestFiles.file_spec("bike.rb", path: :path)
    assert map.sub_directory_match?(watch_file_spec), "should have matched"
    assert map.file_name_match?(File.basename(watch_file_spec)), "should have matched"

    runnable_file_spec = TestFiles.file_spec("bike_test.rb", path: :path)
    target = map.maps.first
    assert target.sub_directory_match?(runnable_file_spec), "should have matched"
    assert target.file_name_match?(File.basename(runnable_file_spec)), "should have matched"

    runnable_file_spec = TestFiles.file_spec("bike_controller_test.rb", path: :path)
    target = map.maps.last
    assert target.sub_directory_match?(runnable_file_spec), "should have matched"
    assert target.file_name_match?(File.basename(runnable_file_spec)), "should have matched"

  end

end
