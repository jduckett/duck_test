require 'test_helper'

class BikeTest < ActiveSupport::TestCase
  include DuckTest::LoggerHelper
  test "bike model test" do
    row = Bike.new(model: "ranger")
    #row = Bike.new(make: "ford", model: "ranger")
    #assert false
    ducklog.console "++++++++++++++++++++++++++++ dude here"
    assert row.save
  end
end
