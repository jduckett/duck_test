class Bike < ActiveRecord::Base
  include DuckTest::LoggerHelper

  #validates_presence_of :make

  before_save :do_something

  def do_something
    ducklog.console "................................... bike"
    return true
  end

end
