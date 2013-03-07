require 'test_helper'

##################################################################################
class WatchableTestObject
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

class WatchableTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = WatchableTestObject.new
    @test_object.root = TestFiles.base_dir
    assert File.exist?(@test_object.root)
  end

  test "should include all trucks implicitly" do
    assert @test_object.watchable?(TestFiles.file_spec("truck_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck_controller_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck_controller"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
  end

  test "should include all trucks explicitly" do
    assert @test_object.watchable?(TestFiles.file_spec("truck_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /^truck/)), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /truck/)), "should be watchable"

    assert @test_object.watchable?(TestFiles.file_spec("truck_controller_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /^truck/)), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck_controller_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /truck/)), "should be watchable"

    assert @test_object.watchable?(TestFiles.file_spec("truck_controller"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /^truck/)), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck_controller"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /truck/)), "should be watchable"

    assert @test_object.watchable?(TestFiles.file_spec("truck"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /^truck/)), "should be watchable"
    assert @test_object.watchable?(TestFiles.file_spec("truck"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included: /truck/)), "should be watchable"

  end

  test "should exclude all trucks explicitly" do
    assert !@test_object.watchable?(TestFiles.file_spec("truck_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /^truck/)), "should not be watchable"
    assert !@test_object.watchable?(TestFiles.file_spec("truck_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /truck/)), "should not be watchable"

    assert !@test_object.watchable?(TestFiles.file_spec("truck_controller_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /^truck/)), "should not be watchable"
    assert !@test_object.watchable?(TestFiles.file_spec("truck_controller_test"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /truck/)), "should not be watchable"

    assert !@test_object.watchable?(TestFiles.file_spec("truck_controller"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /^truck/)), "should not be watchable"
    assert !@test_object.watchable?(TestFiles.file_spec("truck_controller"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /truck/)), "should not be watchable"

    assert !@test_object.watchable?(TestFiles.file_spec("truck"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /^truck/)), "should not be watchable"
    assert !@test_object.watchable?(TestFiles.file_spec("truck"), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded: /truck/)), "should not be watchable"

  end

  test "should include all truck dirs implicitly" do
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*")), "should be watchable"
  end

  test "should include all truck dirs explicitly" do
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /unit/)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /unit/, watch_basedir: :test)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /^unit/, watch_basedir: :test)), "should be watchable"

    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /functional/)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /functional/, watch_basedir: :test)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /^functional/, watch_basedir: :test)), "should be watchable"

    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /controllers/)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /controllers/, watch_basedir: :app)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /^controllers/, watch_basedir: :app)), "should be watchable"

    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /models/)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /models/, watch_basedir: :app)), "should be watchable"
    assert @test_object.watchable?(File.dirname(TestFiles.file_spec("truck")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", included_dirs: /^models/, watch_basedir: :app)), "should be watchable"
  end

  test "should exclude all truck dirs explicitly" do
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /unit/)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /unit/, watch_basedir: :test)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /^unit/, watch_basedir: :test)), "should not be watchable"

    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /functional/)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /functional/, watch_basedir: :test)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller_test")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /^functional/, watch_basedir: :test)), "should not be watchable"

    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /controllers/)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /controllers/, watch_basedir: :app)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /^controllers/, watch_basedir: :app)), "should not be watchable"

    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /controllers/)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /controllers/, watch_basedir: :app)), "should not be watchable"
    assert !@test_object.watchable?(File.dirname(TestFiles.file_spec("truck_controller")), DuckTest::FrameWork::WatchConfig.new(pattern: "**/*", excluded_dirs: /^controllers/, watch_basedir: :app)), "should not be watchable"
  end

end
