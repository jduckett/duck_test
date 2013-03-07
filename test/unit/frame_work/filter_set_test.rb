require 'test_helper'

class FilterSetTest < ActiveSupport::TestCase

  ##################################################################################
  def setup
    @root = File.join(TestFiles.base_dir, "test")
    @subdirectory = "unit"
    @directory = File.join(@root, @subdirectory)
    @file_spec = File.join(@root, @subdirectory, "bike_test.rb")
    assert File.exist?(@file_spec)
  end

  ##################################################################################
  test "should have default values" do
    test_object = DuckTest::FrameWork::FilterSet.new
    assert test_object.included.blank?, "included should be blank"
    assert test_object.included_dirs.blank?, "included_dirs should be blank"
    assert test_object.excluded.blank?, "excluded should be blank"
    assert test_object.excluded_dirs.blank?, "excluded_dirs should be blank"
  end

  test "match_filters? with no parameters should be false" do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?, "match_filters? with no parameters should be false"
  end

  test "match_filters?(nil) should be false" do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil), "match_filters?(nil) should be false"
  end

  test %(match_filters?("") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(""), %(match_filters?("") should be false)
  end

  test %(match_filters?(nil, nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, nil), %(match_filters?(nil, nil) should be false)
  end

  test %(match_filters?("", nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", nil), %(match_filters?("", nil) should be false)
  end

  test %(match_filters?(nil, "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, ""), %(match_filters?(nil, "") should be false)
  end

  test %(match_filters?("", "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", ""), %(match_filters?("", "") should be false)
  end

  test %(match_filters?(nil, nil, nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, nil, nil), %(match_filters?(nil, nil, nil) should be false)
  end

  test %(match_filters?("", nil, nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", nil, nil), %(match_filters?("", nil, nil) should be false)
  end

  test %(match_filters?(nil, "", nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, "", nil), %(match_filters?(nil, "", nil) should be false)
  end

  test %(match_filters?("", "", nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", "", nil), %(match_filters?("", "", nil) should be false)
  end

  test %(match_filters?(nil, nil, "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, nil, ""), %(match_filters?(nil, nil, "") should be false)
  end

  test %(match_filters?("", nil, "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", nil, ""), %(match_filters?("", nil, "") should be false)
  end

  test %(match_filters?(nil, "", "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(nil, "", ""), %(match_filters?(nil, "", "") should be false)
  end

  test %(match_filters?("", "", "") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?("", "", ""), %(match_filters?("", "", "") should be false)
  end

  test %(match_filters?("#{@file_spec}", nil) should be false 2) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, nil), %(match_filters?("#{@file_spec}", nil) should be false)
  end

  test %(match_filters?("#{@file_spec}", []) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, []), %(match_filters?("#{@file_spec}", []) should be false)
  end

  test %(match_filters?("#{@file_spec}", /^book/) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, /^book/), %(match_filters?("#{@file_spec}", /^book/) should be false)
  end

  test %(match_filters?("#{@file_spec}", [/^book/]) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, [/^book/]), %(match_filters?("#{@file_spec}", [/^book/]) should be false)
  end

  test %(match_filters?("#{@file_spec}", [/^book/, /^bike/]) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, [/^book/, /^bike/]), %(match_filters?("#{@file_spec}", [/^book/, /^bike/]) should be true)
  end

  test %(match_filters?("#{@file_spec}", :all) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, :all), %(match_filters?("#{@file_spec}", :all) should be true)
  end

  test %(match_filters?("#{@file_spec}", [:all]) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@file_spec, [:all]), %(match_filters?("#{@file_spec}", [:all]) should be true)
  end

  test %(match_filters?("#{@directory}", nil, @subdirectory) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, nil, @subdirectory), %(match_filters?("#{@directory}", nil, @subdirectory) should be false)
  end

  test %(match_filters?("#{@directory}", [], @subdirectory) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, [], @subdirectory), %(match_filters?("#{@directory}", [], @subdirectory) should be false)
  end

  test %(match_filters?("#{@directory}", /^functional/, @subdirectory) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, /^functional/, @subdirectory), %(match_filters?("#{@directory}", /^functional/, @subdirectory) should be false)
  end

  test %(match_filters?("#{@directory}", [/^functional/], @subdirectory) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, [/^functional/], @subdirectory), %(match_filters?("#{@directory}", [/^functional/], @subdirectory) should be false)
  end

  test %(match_filters?("#{@directory}", [/^functional/, /^unit/], @subdirectory) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, [/^functional/, /^unit/], @subdirectory), %(match_filters?("#{@directory}", [/^functional/, /^unit/], @subdirectory) should be true)
  end

  test %(match_filters?("#{@directory}", :all, @subdirectory) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, :all, @subdirectory), %(match_filters?("#{@directory}", :all, @subdirectory) should be true)
  end

  test %(match_filters?("#{@directory}", [:all], @subdirectory) should be true) do
    assert DuckTest::FrameWork::FilterSet.new.match_filters?(@directory, [:all], @subdirectory), %(match_filters?("#{@directory}", [:all], @subdirectory) should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new.included?(nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.included?(nil), %(DuckTest::FrameWork::FilterSet.new.included?(nil) should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.included?("#{@file_spec}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new.included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new.included?("#{@file_spec}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: nil).included?("#{@file_spec}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new(included: nil).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: nil).included?("#{@file_spec}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: []).included?("#{@file_spec}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new(included: []).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: []).included?("#{@file_spec}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: /^book/).included?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(included: /^book/).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: /^book/).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: [/^book/]).included?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(included: [/^book/]).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: [/^book/]).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: /^bike/).included?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included: /^bike/).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: /^bike/).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: [/^book/, /^bike/]).included?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included: [/^book/, /^bike/]).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: [/^book/, /^bike/]).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: :all).included?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included: :all).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: :all).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included: [:all]).included?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included: [:all]).included?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(included: [:all]).included?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.excluded?(nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.excluded?(nil), %(DuckTest::FrameWork::FilterSet.new.excluded?(nil) should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.excluded?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new.excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: nil).excluded?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded: nil).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: nil).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: []).excluded?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded: []).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: []).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: /^book/).excluded?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded: /^book/).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: /^book/).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: [/^book/]).excluded?("#{@file_spec}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded: [/^book/]).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: [/^book/]).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: /^bike/).excluded?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded: /^bike/).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: /^bike/).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: [/^book/, /^bike/]).excluded?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded: [/^book/, /^bike/]).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: [/^book/, /^bike/]).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: :all).excluded?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded: :all).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: :all).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded: [:all]).excluded?("#{@file_spec}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded: [:all]).excluded?(@file_spec), %(DuckTest::FrameWork::FilterSet.new(excluded: [:all]).excluded?("#{@file_spec}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.included_dirs?(nil, nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.included_dirs?(nil, nil), %(DuckTest::FrameWork::FilterSet.new.included_dirs?(nil, nil) should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.included_dirs?("#{@directory}", "#{@subdirectory}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new.included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new.included_dirs?("#{@directory}", "#{@subdirectory}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: nil).included_dirs?("#{@directory}", "#{@subdirectory}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: nil).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: nil).included_dirs?("#{@directory}", "#{@subdirectory}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: []).included_dirs?("#{@directory}", "#{@subdirectory}") should be true) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: []).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: []).included_dirs?("#{@directory}", "#{@subdirectory}") should be true)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: /^functional/).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(included_dirs: /^functional/).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: /^functional/).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/]).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: /^unit/).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: /^unit/).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: /^unit/).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/, /^unit/]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/, /^unit/]).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: [/^functional/, /^unit/]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: :all).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: :all).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: :all).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(included_dirs: [:all]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(included_dirs: [:all]).included_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(included_dirs: [:all]).included_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.excluded_dirs?(nil, nil) should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.excluded_dirs?(nil, nil), %(DuckTest::FrameWork::FilterSet.new.excluded_dirs?(nil, nil) should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new.excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new.excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new.excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: nil).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded_dirs: nil).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: nil).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: []).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded_dirs: []).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: []).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^functional/).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^functional/).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^functional/).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert !DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/]).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^unit/).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^unit/).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: /^unit/).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/, /^unit/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/, /^unit/]).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/^functional/, /^unit/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/functional/, /unit/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/functional/, /unit/]).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [/functional/, /unit/]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: :all).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded_dirs: :all).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: :all).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

  test %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [:all]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false) do
    assert DuckTest::FrameWork::FilterSet.new(excluded_dirs: [:all]).excluded_dirs?(@directory, @subdirectory), %(DuckTest::FrameWork::FilterSet.new(excluded_dirs: [:all]).excluded_dirs?("#{@directory}", "#{@subdirectory}") should be false)
  end

end













