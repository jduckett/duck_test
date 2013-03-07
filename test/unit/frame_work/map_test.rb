require 'test_helper'

class MapTest < ActiveSupport::TestCase

  ##################################################################################
  test "should have default values" do
    test_object = DuckTest::FrameWork::Map.new
    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"
    assert test_object.maps.kind_of?(Array) && test_object.maps.blank?, "map default should an empty Array"
    assert test_object.runnable_basedir.blank?, "runnable_basedir default should be blank"
    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
  end

  ##################################################################################
  test "should accept sub_directory, file_name, and options" do
    test_object = DuckTest::FrameWork::Map.new(/models/, /bike/, watch_basedir: :app, runnable_basedir: :test)

    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"

    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"

    assert !test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"

    assert !test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end

  ##################################################################################
  test "should accept file_name, and options" do
    test_object = DuckTest::FrameWork::Map.new(/models/, watch_basedir: :app, runnable_basedir: :test)

    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"

    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"

    assert !test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"

    assert !test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end

  ##################################################################################
  test "should accept options" do
    test_object = DuckTest::FrameWork::Map.new(watch_basedir: :app, runnable_basedir: :test)

    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"

    assert !test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"

    assert !test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end

  ##################################################################################
  test "should accept all arguments within options Hash" do
    test_object = DuckTest::FrameWork::Map.new(sub_directory: /models/, file_name: /bike/, watch_basedir: :app, runnable_basedir: :test)

    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"

    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"

    assert !test_object.watch_basedir.blank?, "watch_basedir should not be blank"
    assert test_object.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert test_object.watch_basedir.eql?("app"), "watch_basedir should equal 'app'"

    assert !test_object.runnable_basedir.blank?, "runnable_basedir should not be blank"
    assert test_object.runnable_basedir.kind_of?(String), "runnable_basedir should be of type: String"
    assert test_object.runnable_basedir.eql?("test"), "runnable_basedir should equal 'test'"
  end

  ##################################################################################
  ##################################################################################
  ##################################################################################
  ##################################################################################
  # file names
  test "should assign file_name expression directly via the file_name method" do
    test_object = DuckTest::FrameWork::Map.new
    test_object.file_name /bike/
    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"
  end

  ##################################################################################
  test "should assign file_name expression via a map block" do
    test_object = DuckTest::FrameWork::Map.new do
      file_name /bike/
    end
    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"
  end

  ##################################################################################
  test "should assign file_name expression via map and target blocks" do
    test_object = DuckTest::FrameWork::Map.new do
      file_name /bike/
      target do
        file_name /truck/
      end
    end

    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"

    target = test_object.maps[0]
    assert target.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert target.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert target.file_name.eql?(/truck/), "file_name should equal /truck/"

  end

  ##################################################################################
  test "should assign file_name expression as an Array" do
    test_object = DuckTest::FrameWork::Map.new file_name: [/bike/, :truck, :car, "book", Proc.new {||}]
    assert test_object.sub_directory.eql?("all"), "sub_directory default should be 'all'"
    assert test_object.file_name.kind_of?(Array), "file_name should be of type: Array"
    assert test_object.file_name[0].eql?(/bike/), "expected value: /bike/ actual value: #{test_object.file_name[0]}"
    assert test_object.file_name[1].eql?("truck"), "expected value: 'truck' actual value: #{test_object.file_name[1]}"
    assert test_object.file_name[2].eql?("car"), "expected value: 'car' actual value: #{test_object.file_name[2]}"
    assert test_object.file_name[3].eql?("book"), "expected value: 'book' actual value: #{test_object.file_name[3]}"
    assert test_object.file_name[4].kind_of?(Proc), "expected value: Proc actual value: #{test_object.file_name[4]}"
  end

  ##################################################################################
  test "should match file name against a Symbol" do
    test_object = DuckTest::FrameWork::Map.new file_name: :bike
    assert test_object.file_name_match?("bike_spec.rb"), "file_name should have matched"
    assert !test_object.file_name_match?("truck_spec.rb"), "file_name should not have matched"
  end

  ##################################################################################
  test "should match file name against a String" do
    test_object = DuckTest::FrameWork::Map.new file_name: "bike"
    assert test_object.file_name_match?("bike_spec.rb"), "file_name should have matched"
    assert !test_object.file_name_match?("truck_spec.rb"), "file_name should not have matched"
  end

  ##################################################################################
  test "should match file name against a Regexp" do
    test_object = DuckTest::FrameWork::Map.new file_name: /^bike/
    assert test_object.file_name_match?("bike_spec.rb"), "file_name should have matched"
    assert !test_object.file_name_match?("truck_spec.rb"), "file_name should not have matched"
  end

  ##################################################################################
  test "should match file name against an Array of expressions" do
    test_object = DuckTest::FrameWork::Map.new file_name: [/bike/, :truck, :car, "book", Proc.new {||}]
    assert test_object.file_name_match?("bike_spec.rb"), "file_name should have matched"
    assert test_object.file_name_match?("truck_spec.rb"), "file_name should have matched"
    assert test_object.file_name_match?("car_spec.rb"), "file_name should have matched"
    assert test_object.file_name_match?("book_spec.rb"), "file_name should have matched"
    assert !test_object.file_name_match?("bottle_spec.rb"), "file_name should not have matched"
  end

  ##################################################################################
  ##################################################################################
  ##################################################################################
  ##################################################################################
  ##################################################################################
  # sub-directories
  test "should assign sub_directory expression directly via the sub_directory method" do
    test_object = DuckTest::FrameWork::Map.new
    test_object.sub_directory /models/
    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"
    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"
  end

  ##################################################################################
  test "should assign sub_directory expression via a map block" do
    test_object = DuckTest::FrameWork::Map.new do
      sub_directory /models/
    end
    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"
    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"
  end

  ##################################################################################
  test "should assign sub_directory expression via map and target blocks" do
    test_object = DuckTest::FrameWork::Map.new do
      sub_directory /models/
      target do
        sub_directory /controllers/
      end
    end

    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"
    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"

    target = test_object.maps[0]
    assert target.file_name.eql?("all"), "file_name default should be 'all'"
    assert target.sub_directory.kind_of?(Regexp), "sub_directory should be of type: Regexp"
    assert target.sub_directory.eql?(/controllers/), "sub_directory should equal /controllers/"

  end

  ##################################################################################
  test "should assign sub_directory expression as an Array" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: [/models/, :controllers, :views, "mailers", Proc.new {||}]
    assert test_object.file_name.eql?("all"), "file_name default should be 'all'"
    assert test_object.sub_directory.kind_of?(Array), "sub_directory should be of type: Array"
    assert test_object.sub_directory[0].eql?(/models/), "expected value: /models/ actual value: #{test_object.sub_directory[0]}"
    assert test_object.sub_directory[1].eql?("controllers"), "expected value: 'controllers' actual value: #{test_object.sub_directory[1]}"
    assert test_object.sub_directory[2].eql?("views"), "expected value: 'views' actual value: #{test_object.sub_directory[2]}"
    assert test_object.sub_directory[3].eql?("mailers"), "expected value: 'mailers' actual value: #{test_object.sub_directory[3]}"
    assert test_object.sub_directory[4].kind_of?(Proc), "expected value: Proc actual value: #{test_object.sub_directory[4]}"
  end

  ##################################################################################
  test "should match sub-directory against a Symbol" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: :models
    assert test_object.sub_directory_match?("models"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against a String" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: "models"
    assert test_object.sub_directory_match?("models"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against a Regexp" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: /models/
    assert test_object.sub_directory_match?("models"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against a Symbol with watch_basedir :app" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: :models, watch_basedir: :app
    assert test_object.sub_directory_match?("app/models"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/models/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/models"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/models/sec"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("app/controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against a String with watch_basedir :app" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: "models", watch_basedir: :app
    assert test_object.sub_directory_match?("app/models"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/models/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/models"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/models/sec"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("app/controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against a Regexp with watch_basedir :app" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: /^models/, watch_basedir: :app
    assert test_object.sub_directory_match?("app/models"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/models/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/models"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/models/sec"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("app/controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory with watch_basedir :app against a Regexp with a different comparison from 'begins with'" do
    # regexp's like the following could actually circumvent the watch_basedir
    test_object = DuckTest::FrameWork::Map.new sub_directory: /models/, watch_basedir: :app
    assert test_object.sub_directory_match?("app/models"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/models/sec"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("my_app/models"), "sub_directory should not have matched"
    assert test_object.sub_directory_match?("my_app/models/sec"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("app/controllers"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should match sub-directory against an Array of expressions" do
    test_object = DuckTest::FrameWork::Map.new sub_directory: [/^models/, :controllers, :views, "mailers", Proc.new {||}], watch_basedir: :app

    assert test_object.sub_directory_match?("app/models"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/models/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/models"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/models/sec"), "sub_directory should not have matched"

    assert test_object.sub_directory_match?("app/controllers"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/controllers/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/controllers"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/controllers/sec"), "sub_directory should not have matched"

    assert test_object.sub_directory_match?("app/views"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/views/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/views"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/views/sec"), "sub_directory should not have matched"

    assert test_object.sub_directory_match?("app/mailers"), "sub_directory should have matched"
    assert test_object.sub_directory_match?("app/mailers/sec"), "sub_directory should have matched"
    assert !test_object.sub_directory_match?("my_app/mailers"), "sub_directory should not have matched"
    assert !test_object.sub_directory_match?("my_app/mailers/sec"), "sub_directory should not have matched"
  end

  ##################################################################################
  test "should the target block is added and the runnable_basedir trickles down to the target maps" do
    test_object = DuckTest::FrameWork::Map.new(sub_directory: /models/, file_name: /bike/, watch_basedir: :app, runnable_basedir: :test) do
      target /unit/, /bike_spec/, watch_basedir: :spec
      target /functional/, /bike_controller/
    end

    assert test_object.sub_directory.kind_of?(Regexp), "sub_directory should be of type: String"
    assert test_object.sub_directory.eql?(/models/), "sub_directory should equal /models/"

    assert test_object.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert test_object.file_name.eql?(/bike/), "file_name should equal /bike/"

    assert test_object.maps.length == 2, "expected value: 2 actual value: #{test_object.maps.length}"

    target = test_object.maps[0]
    assert target.sub_directory.kind_of?(Regexp), "sub_directory should be of type: String"
    assert target.sub_directory.eql?(/unit/), "sub_directory should equal /unit/"

    assert target.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert target.file_name.eql?(/bike_spec/), "file_name should equal /bike_spec/"

    assert !target.watch_basedir.blank?, "watch_basedir should not be blank"
    assert target.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert target.watch_basedir.eql?("spec"), "watch_basedir should equal 'spec'"

    assert target.runnable_basedir.blank?, "runnable_basedir should be blank"

    target = test_object.maps[1]
    assert target.sub_directory.kind_of?(Regexp), "sub_directory should be of type: String"
    assert target.sub_directory.eql?(/functional/), "sub_directory should equal /functional/"

    assert target.file_name.kind_of?(Regexp), "file_name should be of type: Regexp"
    assert target.file_name.eql?(/bike_controller/), "file_name should equal /bike_controller/"

    assert !target.watch_basedir.blank?, "watch_basedir should not be blank"
    assert target.watch_basedir.kind_of?(String), "watch_basedir should be of type: String"
    assert target.watch_basedir.eql?("test"), "watch_basedir should equal 'spec'"

    assert target.runnable_basedir.blank?, "runnable_basedir should be blank"
  end

end
