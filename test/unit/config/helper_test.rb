require 'test_helper'

class HelperTestObject
  include DuckTest::ConfigHelper
end

class HelperTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @test_object = HelperTestObject.new
    @test_object.root = '.'
  end

  test "should set default directories" do
    expanded_path = File.expand_path('.')
    assert @test_object.root.eql?(expanded_path), "expected value: '#{expanded_path}' actual value: #{@test_object.root}"
  end

  ##################################################################################
  test "should set the autorun flag" do
    @test_object.autorun = false

    assert !@test_object.autorun, "expected value: false actual value: #{@test_object.autorun}"
  end

  ##################################################################################
  test "watch_basedir should accept a String" do
    @test_object.watch_basedir = "app"
    assert !@test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert @test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert @test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"
  end

  ##################################################################################
  test "watch_basedir should accept a Symbol and convert it to a String" do
    @test_object.watch_basedir = :app
    assert !@test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert @test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert @test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"
  end

  ##################################################################################
  test "runnable_basedir should accept a String" do
    @test_object.runnable_basedir = "test"
    assert !@test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert @test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert @test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end

  ##################################################################################
  test "runnable_basedir should accept a Symbol and convert it to a String" do
    @test_object.runnable_basedir = :test
    assert !@test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert @test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert @test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end


end
