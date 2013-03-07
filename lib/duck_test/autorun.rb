require 'test/unit'

Test::Unit::Runner.class_eval do
  alias_method :original_run, :run
  def run(args = [])
    if DuckTest::FrameWork::Base.ok_to_run
      original_run(args)
    end
  end
end
