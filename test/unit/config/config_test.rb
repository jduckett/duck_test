require 'test_helper'

class ConfigTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    ENV["DUCK_TEST"] = nil
    DuckTest::Config.reset
  end

  ##################################################################################
  test "should always return a Hash without a block" do
    assert DuckTest::Config.config.kind_of?(Hash), "expected value: Hash actual value: #{DuckTest::Config.config}"
  end

  ##################################################################################
  test "should always return a Hash with a block" do
    DuckTest.config do
    end

    assert DuckTest::Config.config.kind_of?(Hash), "expected value: Hash actual value: #{DuckTest::Config.config}"
  end

  ##################################################################################
  test "should have default values without a block" do
    ENV["DUCK_TEST"] = "my_framework"
    assert DuckTest::Config.config.kind_of?(Hash), "expected value: Hash actual value: #{DuckTest::Config.config}"
    assert DuckTest::Config.config[:default_framework].eql?(:testunit), "expected value: :testunit actual value: #{DuckTest::Config.config[:default_framework]}"
    assert !DuckTest::Config.config[:testunit].blank?, "expected value: nil actual value: #{DuckTest::Config.config[:testunit]}"
    assert DuckTest::Config.config[:testunit][:autorun].kind_of?(TrueClass), "expected value: true actual value: #{DuckTest::Config.config[:testunit][:autorun]}"
    assert DuckTest::Config.config[:testunit][:runnable_basedir].eql?("test"), "expected value: test actual value: #{DuckTest::Config.config[:testunit][:runnable_basedir]}"
    assert DuckTest::Config.config[:testunit][:watch_basedir].eql?("app"), "expected value: app actual value: #{DuckTest::Config.config[:testunit][:watch_basedir]}"
  end

  ##################################################################################
  test "should have default values with a block" do
    ENV["DUCK_TEST"] = "my_framework"
    DuckTest.config do
    end
    assert DuckTest::Config.config.kind_of?(Hash), "expected value: Hash actual value: #{DuckTest::Config.config}"
    assert DuckTest::Config.config[:default_framework].eql?(:testunit), "expected value: :testunit actual value: #{DuckTest::Config.config[:default_framework]}"
    assert !DuckTest::Config.config[:testunit].blank?, "expected value: nil actual value: #{DuckTest::Config.config[:testunit]}"
    assert DuckTest::Config.config[:testunit][:autorun].kind_of?(TrueClass), "expected value: true actual value: #{DuckTest::Config.config[:testunit][:autorun]}"
    assert DuckTest::Config.config[:testunit][:runnable_basedir].eql?("test"), "expected value: test actual value: #{DuckTest::Config.config[:testunit][:runnable_basedir]}"
    assert DuckTest::Config.config[:testunit][:watch_basedir].eql?("app"), "expected value: app actual value: #{DuckTest::Config.config[:testunit][:watch_basedir]}"
  end

  ##################################################################################
  test "should set root directory" do

    DuckTest.config do
      root "/my_root"
    end

    assert DuckTest::Config.get_framework(:testunit)[:root].eql?("/my_root"), "expected value: /my_root actual value: #{DuckTest::Config.get_framework(:testunit)[:root]}"

  end

  ##################################################################################
  test "should set default runnable base directory" do

    DuckTest.config do
      runnable_basedir "test"
    end

    assert DuckTest::Config.get_framework(:testunit)[:runnable_basedir].eql?("test"), "expected value: test actual value: #{DuckTest::Config.get_framework(:testunit)[:runnable_basedir]}"

  end

  ##################################################################################
  test "should set default non-runnable base directory" do

    DuckTest.config do
      watch_basedir "app"
    end

    assert DuckTest::Config.get_framework(:testunit)[:watch_basedir].eql?("app"), "expected value: app actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_basedir]}"

  end

  ##################################################################################
  test "should set default autorun" do

    DuckTest.config do
      autorun false
    end

    assert !DuckTest::Config.get_framework(:testunit)[:autorun], "autorun should be false"

  end

  ##################################################################################
  test "should set default autorun for watch configurations" do

    DuckTest.config do
      runnable "**/*"
      watch "**/*"
    end

    assert DuckTest::Config.get_framework(:testunit)[:autorun], "autorun should be true"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun?, "excepted value: true actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun}"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun}"

  end

  ##################################################################################
  test "should override default autorun settings" do

    DuckTest.config do
      autorun false
      runnable "**/*"
      watch "**/*"
    end

    assert !DuckTest::Config.get_framework(:testunit)[:autorun], "autorun should be false"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun}"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun}"

  end

  ##################################################################################
  test "should override default autorun settings per each watch configuration" do

    DuckTest.config do
      runnable "**/*", autorun: false
      watch "**/*"
    end

    assert DuckTest::Config.get_framework(:testunit)[:autorun], "autorun should be true"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun}"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun}"

  end

  ##################################################################################
  test "should not allow autorun to be true unless the watch configuration is runnable" do

    DuckTest.config do
      runnable "**/*"
      watch "**/*", autorun: true
    end

    assert DuckTest::Config.get_framework(:testunit)[:autorun], "autorun should be true"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].autorun}"
    assert !DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun?, "excepted value: false actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].autorun}"

  end

  ##################################################################################
  test "should verify all variations of the included filter are equivalent" do

    DuckTest.config do
      watch "unit01/*", /^trucks/
      watch "unit02/*", [/^trucks/]
      watch "unit03/*", included: /^trucks/
      watch "unit04/*", included: [/^trucks/]
      watch "unit05/*",[/^trucks/, /^cars/]
      watch "unit06/*", included: [/^trucks/, /^cars/]
      watch "unit07/*", :all
      watch "unit08/*", included: :all
      watch "unit09/*", included: [:all]
    end

    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][0].pattern.eql?("unit01/*"), "excepted value: unit01/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][1].pattern.eql?("unit02/*"), "excepted value: unit02/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][2].pattern.eql?("unit03/*"), "excepted value: unit03/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][2].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][3].pattern.eql?("unit04/*"), "excepted value: unit04/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][3].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][4].pattern.eql?("unit05/*"), "excepted value: unit05/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][4].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][5].pattern.eql?("unit06/*"), "excepted value: unit06/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][5].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][6].pattern.eql?("unit07/*"), "excepted value: unit07/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][6].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][7].pattern.eql?("unit08/*"), "excepted value: unit08/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][7].pattern}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][8].pattern.eql?("unit09/*"), "excepted value: unit09/* actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][8].pattern}"

    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][0].filter_set.included.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][0].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][1].filter_set.included.first.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][1].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][2].filter_set.included.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][2].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][3].filter_set.included.first.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][3].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][4].filter_set.included.first.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][4].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][4].filter_set.included[1].eql?(/^cars/), "excepted value: /^cars/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][4].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][5].filter_set.included.first.eql?(/^trucks/), "excepted value: /^trucks/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][5].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][5].filter_set.included[1].eql?(/^cars/), "excepted value: /^cars/ actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][5].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][6].filter_set.included.eql?(:all), "excepted value: :all actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][6].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][7].filter_set.included.eql?(:all), "excepted value: :all actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][7].filter_set.included}"
    assert DuckTest::Config.get_framework(:testunit)[:watch_configs][8].filter_set.included.first.eql?(:all), "excepted value: :all actual value: #{DuckTest::Config.get_framework(:testunit)[:watch_configs][8].filter_set.included}"

  end

end
