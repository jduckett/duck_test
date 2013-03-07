require 'test_helper'

class BasedirTest < ActiveSupport::TestCase

  ##################################################################################
  test "should set and use a default runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      runnable "**/*"
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"

  end

  ##################################################################################
  test "should set and use a default non-runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      watch_basedir :myapp
      watch "**/*"
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
  end

  ##################################################################################
  test "should use and override default runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable "**/*"
      runnable "**/*", watch_basedir: :mytest
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("test"), "excepted value: test actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("test"), "excepted value: test actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][1].watch_basedir}"
    assert framework[:watch_configs][1].runnable_basedir.eql?("test"), "excepted value: test actual value: #{framework[:watch_configs][1].runnable_basedir}"

  end

  ##################################################################################
  test "basedir should taken precedence of watch_basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable "**/*"
      runnable "**/*", basedir: :base_test, watch_basedir: :watch_base_test
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("test"), "excepted value: test actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("test"), "excepted value: test actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("base_test"), "excepted value: base_test actual value: #{framework[:watch_configs][1].watch_basedir}"
    assert framework[:watch_configs][1].runnable_basedir.eql?("base_test"), "excepted value: base_test actual value: #{framework[:watch_configs][1].runnable_basedir}"

  end

  ##################################################################################
  test "should set, use, and override runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :other_tests
      runnable "**/*"
      runnable "**/*", runnable_basedir: :mytest
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].runnable_basedir.eql?("other_tests"), "excepted value: other_tests actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][1].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][1].runnable_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][1].watch_basedir}"

  end

  ##################################################################################
  test "basedir should override runnable_basedir passed to runnable" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :other_tests
      runnable "**/*"
      runnable "**/*", basedir: :base_override, runnable_basedir: :mytest
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].runnable_basedir.eql?("other_tests"), "excepted value: other_tests actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][1].runnable_basedir.eql?("base_override"), "excepted value: base_override actual value: #{framework[:watch_configs][1].runnable_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("base_override"), "excepted value: base_override actual value: #{framework[:watch_configs][1].watch_basedir}"

  end

  ##################################################################################
  test "should use and override default non-runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      watch "**/*"
      watch "**/*", watch_basedir: :myapp
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("app"), "excepted value: app actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][1].watch_basedir}"

  end

  ##################################################################################
  test "should set, use, and override non-runnable basedir" do

    DuckTest::Config.reset
    DuckTest.config do
      watch_basedir :other_app
      watch "**/*"
      watch "**/*", watch_basedir: :myapp
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("other_app"), "excepted value: other_app actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][1].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][1].watch_basedir}"

  end

  ##################################################################################
  test "should use default basedir values for new watch configurations" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*"
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"

  end

  ##################################################################################
  test "should override default basedir values for new watch configurations" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*", watch_basedir: :other_app, runnable_basedir: :other_target
    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("other_app"), "excepted value: other_app actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("other_target"), "excepted value: other_target actual value: #{framework[:watch_configs][0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a simple map to a watch configuration" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map /models/, /[a-z]/

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("myapp"), "excepted value: 'myapp' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("mytest"), "excepted value: 'mytest' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a simple map to a watch configuration while overriding basedir on the map definition" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map /models/, /[a-z]/, watch_basedir: :map_app, runnable_basedir: :map_target

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("map_app"), "excepted value: 'map_app' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("map_target"), "excepted value: 'map_target' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block to a watch configuration" do

    DuckTest::Config.reset
    DuckTest.config do
      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map do
          sub_directory /models/
          file_name /[a-z]/
        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("myapp"), "excepted value: 'myapp' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("mytest"), "excepted value: 'mytest' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block including a target" do

    DuckTest::Config.reset
    DuckTest.config do

      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map do
          sub_directory /models/
          file_name /[a-z]/

          target /unit/, /[a-z]_specs/

        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("myapp"), "excepted value: 'myapp' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("mytest"), "excepted value: 'mytest' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

    assert framework[:watch_configs][0].maps[0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps[0].maps.length}"
    assert framework[:watch_configs][0].maps[0].maps[0].sub_directory.eql?(/unit/), "excepted value: /unit/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].maps[0].file_name.eql?(/[a-z]_specs/), "excepted value: /[a-z]_specs/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].maps[0].watch_basedir.eql?("mytest"), "excepted value: 'mytest' actual value: #{framework[:watch_configs][0].maps[0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].maps[0].runnable_basedir.blank?, "excepted value: nil actual value: #{framework[:watch_configs][0].maps[0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block including a target via block" do

    DuckTest::Config.reset
    DuckTest.config do

      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map do
          sub_directory /models/
          file_name /[a-z]/

          target watch_basedir: :target_runnable do
            sub_directory /unit/
            file_name /[a-z]_specs/
          end

        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("myapp"), "excepted value: 'myapp' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("mytest"), "excepted value: 'mytest' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

    assert framework[:watch_configs][0].maps[0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps[0].maps.length}"
    assert framework[:watch_configs][0].maps[0].maps[0].sub_directory.eql?(/unit/), "excepted value: /unit/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].maps[0].file_name.eql?(/[a-z]_specs/), "excepted value: /[a-z]_specs/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].maps[0].watch_basedir.eql?("target_runnable"), "excepted value: 'target_runnable' actual value: #{framework[:watch_configs][0].maps[0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].maps[0].runnable_basedir.blank?, "excepted value: nil actual value: #{framework[:watch_configs][0].maps[0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block including a target via block and pick up basedirs from map definition" do

    DuckTest::Config.reset
    DuckTest.config do

      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map watch_basedir: :map_app, runnable_basedir: :map_target do
          sub_directory /models/
          file_name /[a-z]/

          target do
            sub_directory /unit/
            file_name /[a-z]_specs/
          end

        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("map_app"), "excepted value: 'map_app' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("map_target"), "excepted value: 'map_target' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

    assert framework[:watch_configs][0].maps[0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps[0].maps.length}"
    assert framework[:watch_configs][0].maps[0].maps[0].sub_directory.eql?(/unit/), "excepted value: /unit/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].maps[0].file_name.eql?(/[a-z]_specs/), "excepted value: /[a-z]_specs/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].maps[0].watch_basedir.eql?("map_target"), "excepted value: 'map_target' actual value: #{framework[:watch_configs][0].maps[0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].maps[0].runnable_basedir.blank?, "excepted value: nil actual value: #{framework[:watch_configs][0].maps[0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block including a target via block and override basedirs from map definition" do

    DuckTest::Config.reset
    DuckTest.config do

      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*" do

        map watch_basedir: :map_app, runnable_basedir: :map_target do
          sub_directory /models/
          file_name /[a-z]/

          target watch_basedir: :target_runnable do
            sub_directory /unit/
            file_name /[a-z]_specs/
          end

        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("myapp"), "excepted value: myapp actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("mytest"), "excepted value: mytest actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("map_app"), "excepted value: 'map_app' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("map_target"), "excepted value: 'map_target' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

    assert framework[:watch_configs][0].maps[0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps[0].maps.length}"
    assert framework[:watch_configs][0].maps[0].maps[0].sub_directory.eql?(/unit/), "excepted value: /unit/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].maps[0].file_name.eql?(/[a-z]_specs/), "excepted value: /[a-z]_specs/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].maps[0].watch_basedir.eql?("target_runnable"), "excepted value: 'target_runnable' actual value: #{framework[:watch_configs][0].maps[0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].maps[0].runnable_basedir.blank?, "excepted value: nil actual value: #{framework[:watch_configs][0].maps[0].maps[0].runnable_basedir}"

  end

  ##################################################################################
  test "should add a map via block including a target via block and use basedirs from watch directive" do

    DuckTest::Config.reset
    DuckTest.config do

      runnable_basedir :mytest
      watch_basedir :myapp
      watch "**/*", basedir: :map_app, runnable_basedir: :map_target do

        map do
          sub_directory /models/
          file_name /[a-z]/

          target watch_basedir: :target_runnable do
            sub_directory /unit/
            file_name /[a-z]_specs/
          end

        end

      end

    end

    framework = DuckTest::Config.get_framework(:testunit)
    assert framework[:watch_configs][0].watch_basedir.eql?("map_app"), "excepted value: map_app actual value: #{framework[:watch_configs][0].watch_basedir}"
    assert framework[:watch_configs][0].runnable_basedir.eql?("map_target"), "excepted value: map_target actual value: #{framework[:watch_configs][0].runnable_basedir}"
    assert framework[:watch_configs][0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps.length}"
    assert framework[:watch_configs][0].maps[0].sub_directory.eql?(/models/), "excepted value: /models/ actual value: #{framework[:watch_configs][0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].file_name.eql?(/[a-z]/), "excepted value: /[a-z]/ actual value: #{framework[:watch_configs][0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].watch_basedir.eql?("map_app"), "excepted value: 'map_app' actual value: #{framework[:watch_configs][0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].runnable_basedir.eql?("map_target"), "excepted value: 'map_target' actual value: #{framework[:watch_configs][0].maps[0].runnable_basedir}"

    assert framework[:watch_configs][0].maps[0].maps.length == 1, "excepted value: 1 actual value: #{framework[:watch_configs][0].maps[0].maps.length}"
    assert framework[:watch_configs][0].maps[0].maps[0].sub_directory.eql?(/unit/), "excepted value: /unit/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].sub_directory}"
    assert framework[:watch_configs][0].maps[0].maps[0].file_name.eql?(/[a-z]_specs/), "excepted value: /[a-z]_specs/ actual value: #{framework[:watch_configs][0].maps[0].maps[0].file_name}"
    assert framework[:watch_configs][0].maps[0].maps[0].watch_basedir.eql?("target_runnable"), "excepted value: 'target_runnable' actual value: #{framework[:watch_configs][0].maps[0].maps[0].watch_basedir}"
    assert framework[:watch_configs][0].maps[0].maps[0].runnable_basedir.blank?, "excepted value: nil actual value: #{framework[:watch_configs][0].maps[0].maps[0].runnable_basedir}"

  end

end
