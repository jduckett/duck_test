# this is unfinished code that was not implemented
# the original idea was to alter OptionParser class to grab and remove
# arguments from the CLI prior to the console loading fully as it will
# puke with an error if a user passes invalid arguments.
# the desire was to somehow grab a CLI arg from a user and set the session
# to load while still allowing the user to use the standard rails command

# like: rails c test

# i would have like to do something like: rails c test --duck=rspec

# then, remove the argument from ARGV and let rails c test continue
# the test of the idea actually worked, however, i never actually coded a solution, because,
# i thought it might make the gem to brittle to use.  I may decide to implement it at a later
# date after more thought.  for now, the current solution was to simply create an executable
# that grabs the args and fire up the console.

# class OptionParser
# 
#   alias_method :my_parse!, :parse!
# 
#   def parse!(x)
# 
#     value = ARGV.find {|item| item =~ /^--duck/ || item =~ /^-duck/}
#     ARGV.delete_if {|item| item =~ /^--duck/ || item =~ /^-duck/}
# 
#     my_parse!(x)
#   end
# 
# end
