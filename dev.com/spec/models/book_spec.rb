require 'spec_helper'

include DuckTest::LoggerHelper

describe Book do

  it "is greater than 4" do
    ducklog.console "................. duck!"
    5.should be > 4
  end

  it "wtf" do
    x = Book.new.my_method
    x.should == "yes"
  end

end

