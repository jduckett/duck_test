# this set of tests was causing all types of problems, because, it is writing to files.
# need to refactor how it should be simulating a file being changed
#require 'test_helper'
#require 'digest/sha1'

#class ClientObject
  #def listener_event(event)
    #return "triggered"
  #end
#end

#class ListenerTestObject
  #include DuckTest::Platforms::Listener

  #def write_random_string(file_spec)
    #file = nil

    #begin
      #file = File.open(file_spec, "w")
      #file.write (0...250).map{ ('a'..'z').to_a[rand(26)] }.join
    #rescue Exception => e
      #puts e
      #puts e.backtrace.join("\n")
    #ensure
      #file.close if file
    #end
  #end
#end

#class ListenerTest < ActiveSupport::TestCase

  ###################################################################################
  #def setup
    #@test_object = ListenerTestObject.new
  #end

  ###################################################################################
  #test "dir_list should be an empty array by default" do
    #assert @test_object.dir_list.kind_of?(Array), "expected value: Array actual value: #{@test_object.dir_list.class.name}"
    #assert @test_object.dir_list.blank?, "expected value: [] actual value: #{@test_object.dir_list}"
  #end

  ###################################################################################
  #test "file_list should be an empty array by default" do
    #assert @test_object.file_list.kind_of?(Hash), "expected value: Hash actual value: #{@test_object.file_list.class.name}"
    #assert @test_object.file_list.blank?, "expected value: {} actual value: #{@test_object.file_list}"
  #end

  ###################################################################################
  #test "self.stop should be false by default" do
    #assert !@test_object.stop, "expected value: false actual value: #{@test_object.stop}"
  #end

  ###################################################################################
  #test "should set the value of self.stop" do
    #assert !@test_object.stop, "expected value: false actual value: #{@test_object.stop}"
    #@test_object.stop = true
    #assert @test_object.stop, "expected value: true actual value: #{@test_object.stop}"
  #end

  ###################################################################################
  #test "should set listener event block" do
    #assert @test_object.block.blank?, "expected value: nil actual value: #{@test_object.block}"
    #@test_object.listener_event {|event| puts event}
    #assert @test_object.block.kind_of?(Proc), "expected value: Proc.new actual value: #{@test_object.block}"
  #end

  ###################################################################################
  #test "should trigger listener event" do
    #client_object = ClientObject.new
    #@test_object.listener_event {|event| client_object.listener_event(event)}
    #value = @test_object.call_listener_event(WatchEvent.new(self, "test.rb", :update))
    #assert value.eql?("triggered"), "expected value: triggered actual value: #{value}"
  #end

  ###################################################################################
  #test "should watch a directory via watch_file_spec method" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.watch_file_spec(file_spec)
    #assert @test_object.dir_list.include?(file_spec), "should be found in dir_list: #{file_spec}"
    #assert !@test_object.file_list[file_spec].blank?, "should be found in file_list: #{file_spec}"
  #end

  ###################################################################################
  #test "should watch a directory via watch method" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.watch(file_spec)
    #assert @test_object.dir_list.include?(file_spec), "should be found in dir_list: #{file_spec}"
    #assert !@test_object.file_list[file_spec].blank?, "should be found in file_list: #{file_spec}"
  #end

  ###################################################################################
  #test "should watch a file via watch_file_spec method" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.watch_file_spec(file_spec)
    #assert !@test_object.dir_list.include?(file_spec), "should be found in dir_list: #{file_spec}"
    #assert !@test_object.file_list[file_spec].blank?, "should be found in file_list: #{file_spec}"
  #end

  ###################################################################################
  #test "should watch a file via watch method" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.watch(file_spec)
    #assert !@test_object.dir_list.include?(file_spec), "should be found in dir_list: #{file_spec}"
    #assert !@test_object.file_list[file_spec].blank?, "should be found in file_list: #{file_spec}"
  #end

  ###################################################################################
  #test "directory status should be watched" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.watch(file_spec)
    #assert @test_object.watched?(file_spec), "file should be watched: #{file_spec}"
  #end

  ###################################################################################
  #test "directory status should NOT be watched" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #assert !@test_object.watched?(file_spec), "file should NOT be watched: #{file_spec}"
  #end

  ###################################################################################
  #test "directory status should NOT be changed if NOT watched" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #assert !@test_object.changed?(file_spec), "directory should NOT be changed if NOT watched: #{file_spec}"
  #end

  ###################################################################################
  #test "directory status should NOT be changed" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.watch(file_spec)
    #assert !@test_object.changed?(file_spec), "directory should NOT be changed: #{file_spec}"
  #end

  ###################################################################################
  ## not sure the importantance of this test.
  ## really don't like using sleep in a test.  if it causes a real problem, then, remove it
  #test "directory status SHOULD be changed" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.watch(file_spec)
    #assert !@test_object.changed?(file_spec), "directory should NOT be changed at this point: #{file_spec}"
    #sleep(0.5)
    #FileUtils.touch(file_spec)
    #assert @test_object.changed?(file_spec), "directory SHOULD be changed: #{file_spec}"
  #end

  ###################################################################################
  #test "file status should be watched" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.watch(file_spec)
    #assert @test_object.watched?(file_spec), "file should be watched: #{file_spec}"
  #end

  ###################################################################################
  #test "file status should NOT be watched" do
    #file_spec = TestFiles.file_spec("bike_test")
    #assert !@test_object.watched?(file_spec), "file should NOT be watched: #{file_spec}"
  #end

  ###################################################################################
  #test "file status should NOT be changed if NOT watched" do
    #file_spec = TestFiles.file_spec("bike_test")
    #assert !@test_object.changed?(file_spec), "file should NOT be changed if NOT watched: #{file_spec}"
  #end

  ###################################################################################
  #test "file status should NOT be changed" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.watch(file_spec)
    #assert !@test_object.changed?(file_spec), "file should NOT be changed: #{file_spec}"
  #end

  ###################################################################################
  #test "file status SHOULD be changed" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.watch(file_spec)
    #assert !@test_object.changed?(file_spec), "file should NOT be changed at this point: #{file_spec}"
    #@test_object.write_random_string(file_spec)
    #assert @test_object.changed?(file_spec), "file SHOULD be changed: #{file_spec}"
  #end

  ###################################################################################
  #test "should update directory spec attributes" do
    #file_spec = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full).first
    #@test_object.update_file_spec(file_spec)
    #file_object = @test_object.file_list[file_spec]

    #assert file_object, "file_object should not be nil"
    #assert @test_object.watched?(file_spec), "file should be watched: #{file_spec}"
    #assert file_object[:mtime].eql?(File.mtime(file_spec).to_f), "#{file_object[:mtime]} does not match: #{File.mtime(file_spec).to_f}"
    #assert file_object[:is_dir], "SHOULD be a directory: #{file_spec}"
  #end

  ###################################################################################
  #test "should update file spec attributes" do
    #file_spec = TestFiles.file_spec("bike_test")
    #@test_object.update_file_spec(file_spec)
    #file_object = @test_object.file_list[file_spec]

    #assert file_object, "file_object should not be nil"
    #assert @test_object.watched?(file_spec), "file should be watched: #{file_spec}"
    #assert file_object[:mtime].eql?(File.mtime(file_spec).to_f), "#{file_object[:mtime]} does not match: #{File.mtime(file_spec).to_f}"
    #assert file_object[:sha].eql?(Digest::SHA1.file(file_spec).to_s), "#{file_object[:sha]} does not match: #{Digest::SHA1.file(file_spec).to_s}"
    #assert !file_object[:is_dir], "should not be a directory: #{file_spec}"
  #end

  ###################################################################################
  #test "should update ALL file spec attributes" do
    ## get a list of files, write a random string to all of them, then, watch all of them
    #list = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/}, path: :full)
    #list.each {|file_spec| @test_object.write_random_string(file_spec)}
    #list.each {|file_spec| @test_object.watch(file_spec)}

    ## none of them should have changed yet
    #list.each {|file_spec| assert !@test_object.changed?(file_spec), "file should NOT be changed yet: #{file_spec}"}

    ## now, write a random string to all of them again
    #list.each {|file_spec| @test_object.write_random_string(file_spec)}

    ## all of them should have changed
    #list.each {|file_spec| assert @test_object.changed?(file_spec), "file should be changed after write_random_string: #{file_spec}"}

    ## update the attributes for all files being watched
    #@test_object.update_all

    ## none of them should been considered changed now
    #list.each {|file_spec| assert !@test_object.changed?(file_spec), "file should NOT be changed again: #{file_spec}"}

  #end

  ###################################################################################
  #test "should find nothing unless files have changed" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #list = @test_object.refresh
    #assert list.blank?, "Nothing has changed, therefore, changed list should be blank"

  #end

  ###################################################################################
  #test "should find two changed files" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #list = @test_object.refresh
    #assert list.blank?, "Nothing has changed, therefore, changed list should be blank"

    #@test_object.write_random_string(files.first)
    #@test_object.write_random_string(files.last)

    #list = @test_object.refresh
    #assert list.length == 2, "expected value: 2 actual list of changed files: #{list.length}"

  #end

  ###################################################################################
  #test "should find multiple changed files" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #list = @test_object.refresh
    #assert list.blank?, "Nothing has changed, therefore, changed list should be blank"

    #@test_object.write_random_string(files.first)
    #@test_object.write_random_string(files.last)

    #list = @test_object.refresh
    #assert list.length == 2, "expected value: 2 actual list of changed files: #{list.length}"

    #files.each {|item| @test_object.write_random_string(item)}
    #list = @test_object.refresh
    #assert list.length == files.length, "expected value: #{files.length} actual list of changed files: #{list.length}"

  #end

  ###################################################################################
  #test "should find a new directory" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #file_spec = "#{File.dirname(files.first)}/new_dir"
    #FileUtils.mkdir(file_spec)
    #buffer = @test_object.dir_list.length
    #list = @test_object.refresh
    #assert @test_object.dir_list.length == (buffer + 1), "expected value: #{buffer + 1} actual list of changed files: #{@test_object.dir_list.length}"

    #FileUtils.rmdir(file_spec)

  #end

  ###################################################################################
  #test "should recognize a directory has been deleted" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #file_spec = "#{File.dirname(files.first)}/new_dir"
    #FileUtils.mkdir(file_spec)
    #buffer = @test_object.dir_list.length
    #list = @test_object.refresh
    #assert @test_object.dir_list.length == (buffer + 1), "expected value: #{buffer + 1} actual list of changed files: #{@test_object.dir_list.length}"

    #FileUtils.rmdir(file_spec)
    #list = @test_object.refresh
    #assert @test_object.dir_list.length == buffer, "expected value: #{buffer} actual list of changed files: #{@test_object.dir_list.length}"

  #end

  ###################################################################################
  #test "should find a new file" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #file_spec = "#{File.dirname(files.first)}/new_file.rb"
    #FileUtils.touch(file_spec)
    #@test_object.write_random_string(file_spec)
    #list = @test_object.refresh
    #assert list.length == 1, "expected value: 1 actual list of changed files: #{list.length}"

    #FileUtils.rm(file_spec)

  #end

  ###################################################################################
  #test "should find a file has been deleted" do
    #dirs = TestFiles.find_dirs(dir: :test, pattern: /^unit/, path: :full)
    #files = TestFiles.find_files(dirs: {dir: :test, pattern: /^unit/, path: :full}, pattern: :all, path: :full)
    #dirs.each {|item| @test_object.watch(item)}
    #files.each {|item| @test_object.watch(item)}

    #file_spec = "#{File.dirname(files.first)}/new_file.rb"
    #FileUtils.touch(file_spec)
    #@test_object.write_random_string(file_spec)

    #buffer = @test_object.file_list.length
    #list = @test_object.refresh
    #assert @test_object.file_list.length == (buffer + 1), "expected value: #{buffer + 1} actual list of changed files: #{@test_object.file_list.length}"

    #FileUtils.rm(file_spec)
    #list = @test_object.refresh
    #assert @test_object.file_list.length == buffer, "expected value: #{buffer} actual list of changed files: #{@test_object.file_list.length}"
  #end

#end

















