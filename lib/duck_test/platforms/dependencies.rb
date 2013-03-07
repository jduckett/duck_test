# this file is loaded via the gem and it's purpose is to load a platform specific gem that provides file watching functionality.
# I chose to put this in a separate file in the event that I add more platforms or if more logic is needed making the code a bit lengthy.
begin

  if DuckTest::Platforms::OSHelper.is_linux?
    require "rb-inotify"

  elsif DuckTest::Platforms::OSHelper.is_mac?
    require "rb-fsevent"

  elsif DuckTest::Platforms::OSHelper.is_windows?
    require "rb-fchange"

  end

rescue Exception => e
  puts e
end