require 'test_helper'

class WatchConfigTest < ActiveSupport::TestCase

  ##################################################################################
  test "should have default values" do
    watch_config = DuckTest::FrameWork::WatchConfig.new
    assert !watch_config.filter_set.blank?, "filter_set should not be blank"
    assert watch_config.filter_set.included.blank?, "filter_set.included should be blank"
    assert watch_config.filter_set.included_dirs.blank?, "filter_set.included_dirs should be blank"
    assert watch_config.filter_set.excluded.blank?, "filter_set.excluded should be blank"
    assert watch_config.filter_set.excluded_dirs.blank?, "filter_set.excluded_dirs should be blank"
    assert watch_config.maps.kind_of?(Array), "maps should be an Array"
    assert watch_config.maps.blank?, "maps should be empty"
    assert watch_config.pattern.blank?, "pattern should be empty"
    assert watch_config.watch_basedir.blank?, "watch_basedir should be empty"
    assert watch_config.runnable_basedir.blank?, "runnable_basedir should be empty"
    assert !watch_config.runnable, "runnable should be false"
    assert !watch_config.runnable?, "runnable should be false"
  end

  test "filter_set should be empty by default" do
    watch_config = DuckTest::FrameWork::WatchConfig.new
    assert !watch_config.filter_set.blank?, "filter_set should exist"
    assert !watch_config.filter_set.has_included?, "filter_set.has_included? should be empty"
    assert !watch_config.filter_set.has_included_dirs?, "filter_set.has_included_dirs? should be empty"
    assert !watch_config.filter_set.has_excluded?, "filter_set.has_excluded? should be empty"
    assert !watch_config.filter_set.has_excluded_dirs?, "filter_set.has_excluded_dirs? should be empty"
  end

  test "should accept a preconfigured filter set" do
    watch_config = DuckTest::FrameWork::WatchConfig.new(filter_set: DuckTest::FrameWork::FilterSet.new(included: /test/, included_dirs: /test/, excluded: /test/, excluded_dirs: /test/))
    assert !watch_config.filter_set.blank?, "filter_set should exist"
    assert watch_config.filter_set.has_included?, "filter_set.has_included? should NOT be empty"
    assert watch_config.filter_set.has_included_dirs?, "filter_set.has_included_dirs? should NOT be empty"
    assert watch_config.filter_set.has_excluded?, "filter_set.has_excluded? should NOT be empty"
    assert watch_config.filter_set.has_excluded_dirs?, "filter_set.has_excluded_dirs? should NOT be empty"
  end

end













