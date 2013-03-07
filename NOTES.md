- colored logging?
- at this point, definitely not going to load different framework on the fly.  i don't trust the file notifiers will actually shutdown correctly.  i don't want notifiers triggering tests
  when they are not suppose to.  besides, likelyhood that developers will have more than one framework is very low anyway.
- Automagically determine the testing framework being used by the app and set it as the default / target framework to load at start up.
- Allow developer to force which listener to use: linux, mac, windoze, generic
- shutdown framework, listeners, queue, etc. and switch to another framework via a command.  keep multiple frameworks running in memory??
- make DuckTest work outside of Rails
- tweak RSpec to reset the start/duration each time tests are run.
- support for cucumber??  doesn't look like it will be possible right now
- get shoulda to work

TODO Should be able to run the debugger from a test.


# RUBY_VERSION
# RUBY_PATCHLEVEL
# RUBY_PLATFORM
# RUBY_RELEASE_DATE
# RUBY_REVISION


