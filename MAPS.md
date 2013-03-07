# Mapping non-runnable files to runnrable test files

DuckTest provides the ability to watch non-runnable application files for changes and automagically execute runnable tests associated with the watched files.  Basically, you "map"
application (non-runnable) files to runnable test files.  {DuckTest::FrameWork::Map} represents the attributes and methods needed to accomplish that task.  When a file changes, FileManager
is notified and determines if the file is a non-runnable or runnable file.  If non-runnable, it will determine if there are any runnable files associated with it based on an array of
map objects.  {DuckTest::FrameWork::FileManager#white_list} maintains a reference to the {DuckTest::FrameWork::WatchConfig} object that was responsible for adding it to the list.  Therefore,
the map objects for that watch config object are used to find runnable files.  It is important to keep in mind that map objects are associated directly with a watch config object and
indirectly with a file.  Therefore, the list of map objects needs to be traversed and compared against the non-runnable file.  If a match is found, the white list is searched and compared
against each one of the targets associated with the map object.  Files that match when evaluated are considered runnable files and are added to the queue to be executed.

The following example maps all files that begin with book under the models sub-directory to all files that begin with book_test under the unit sub-directory and all files that begin with
books_controller_test under the functional sub-directory.  This is a very specific mapping.  You have the power via Regexp and code blocks to select just about any combination to fit just
about any need.

    DuckTest.config do
      watch "**/*" do
        map /^models/, /^book/ do                         # application (non-runnable).  also referred to as source files.
          target /^unit/, /book_test/                     # runnable test files.  also referred to as target files.
          target /^functional/, /books_controller_test/
        end
      end
    end

When evaluating the current non-runnable file, {DuckTest::FrameWork::FileManager#find_runnable_files} will pass the current non-runnable file specification to the expression.  When evaluating
potential runnable target files, {DuckTest::FrameWork::FileManager#find_runnable_files} will pass both the current non-runnable and the potential runnable file to the expression.  This should
provide enough flexibility to meet most situations.

    # here, value is the current non-runnable file and cargo is the potential runnable target file
    watch "**/*" do
      map do
        target :all do
          file_name do |value, cargo|
            value =~ /#{File.basename(cargo, ".rb")}_test.rb/ ? true : false
          end
        end
      end
    end

    # same thing just shorter
    watch "**/*" do
      map do
        target :all do
          file_name {|value, cargo| value =~ /#{File.basename(cargo, ".rb")}_test.rb/}
        end
      end
    end

watch_basedir plays an important role in the evaluation of sub-directories.  A typical layout of a Rails app might look like the following:

    /home/my_home/test_app/app/assets
                              /controllers
                              /controllers/bikes_controller.rb
                              /helpers
                              /mailers
                              /models
                              /models/bike.rb
                              /views
                              /views/bikes
                              /views/layout

    /home/my_home/test_app/test
                                /fixtures
                                /functional
                                /functional/bikes_controller_test.rb
                                /integration
                                /performance
                                /unit
                                /unit/bike_spec.rb

The following is a direct mapping.  When the /models/bike.rb file changes we want the tests contained in /unit/bike_spec.rb to automagically run.

    map = Map.new(:models, /^bike/, watch_basedir: :app, runnable_basedir: :test do
      target :unit, /^bike_spec/
    end

Notice that watch_basedir is set to :app.  When a sub-directory is evaluated by {DuckTest::FrameWork::FileManager#find_runnable_files}, the full sub-directory
excluding the Rails.root is passed to {DuckTest::FrameWork::Map#sub_directory_match?}.  Without the use of watch_basedir you would have to specify mappings like:

    map = Map.new("app/models", /^bike/, watch_basedir: :app, runnable_basedir: :test do
      target :unit, /^bike_spec/
    end

Configuration files would get messy quickly.  When {DuckTest::FrameWork::Map#sub_directory_match?} evaluates a sub-directory the watch_basedir is removed
from the sub_directory values prior to evaluation.  It would be possible to simply use Regexps to do this work for us, but, that could get
complicated as well and it would not allow the use of Symbols for sub-directory names.  The only difference it the manner {DuckTest::FrameWork::Map#file_name_match?}
and {DuckTest::FrameWork::Map#sub_directory_match?} work is that {DuckTest::FrameWork::Map#sub_directory_match?} does some extra work to remove
the sub_directory from the front on the value.  Otherwise, both methods work the same.

You have the option of passing a Proc, Regexp, String, Symbol, or an Array of any combination of the first four types to {DuckTest::FrameWork::Map#file_name_match?}
and {DuckTest::FrameWork::Map#sub_directory_match?}

Here is how they are evaluated.  If you pass a...
- Symbol The Symbol is converted to a String and processed as a String.
- String The String expression is compared against the beginning of the directory / file name.  If the directory / file name
  begins with the String, then, it is considered a match and returns true.  Also, you can pass a special Symbol or String named
  :all or "all", which will evaluate to true for all values.
- Regexp are handled in a straight-forward manner:  value =~ expression
- Proc Blocks are executed and pass the directory / file name as well as an extra value named cargo.  {DuckTest::FrameWork::FileManager} uses cargo
  to pass the file name of the watched file that triggered the change when comparing expression against the runnable file.
