[![Build Status](https://secure.travis-ci.org/jduckett/duck_test.png?branch=master)](http://travis-ci.org/jduckett/duck_test)

**Homepage**:       [http://jeffduckett.com](http://jeffduckett.com)

**Git**:            [http://github.com/jduckett/duck_test](http://github.com/jduckett/duck_test)

**Documentation**:  [http://rubydoc.info/github/jduckett/duck_test/frames](http://rubydoc.info/github/jduckett/duck_test/frames)

**Author**:         Jeff Duckett

**Copyright**:      2012

**License**:        MIT License

# Duck Test
Duck Test facilitates running tests within the Rails IRB console.

# Overview
Running tests are essential to solid application development and the standard Rails mechanism for running tests does a fine job.  However, as the Rails framework has matured
coupled with the plethora of gems available to developers the start up of the Rails environment can increase to a point that can make TDD a bit painful.  Ducktest runs within
the Rails console allowing the developer to run the Rails environment in the console and develop tests rapidly.  Ducktest recognizes when test files have changed and runs them
automagically within a second.

<span class="note">It is very important to note that Ducktest is intended for rapid development of Rails tests by editing runnable test and having them run immediately.
You should continue to run the entire test suite in the normal fashion.</span>

# Requirements
DuckTest was developed on a 64-bit Ubuntu Linux box using Ruby 1.9.3p0, Rails 3.2.1, and rubygems 1.8.11  The codebase uses the 1.9 Hash syntax

     # 1.9 style
     x = {autorun: true, basedir: "/tmp"}

     # prior 1.9
     x = {:autorun => true, :basedir => "/tmp"}

Therefore, you need 1.9 or greater to use this gem.  Also, I haven't done ANY testing on earlier versions of Rails, so, I have no idea what will work.
Use at your own risk.

# Quick start

Create a new rails app named test.com

    rails new test.com --skip-bundle

Edit test.com/Gemfile and add the following to your test group

    group :test do
      # ... existing gems
      gem 'turn', :require => false
      gem 'duck_test'
    end

Run bundle

    bundle install

Generate a scaffold with some tests, then, migrate and prepare the test environment

    rails g scaffold book author:string title:string
    rake db:migrate
    rake test:prepare

Run the Rails console

    rails c test

Edit one of the test files: test/unit/book_test.rb

    require 'test_helper'
    class BookTest < ActiveSupport::TestCase
      test "the truth" do
        assert false
      end
    end

Look at the Rails console and you should see that the test automagically ran and failed.  Go back and change the assert from false to true and save.  The test should run again and pass.

To see it in action, have a look at the following video:  {http://www.youtube.com/watch?v=AULj1MR0WD0}

# Watching files and running tests

DuckTest automagically runs tests by watching directories and files for changes.  You define the files that are watched and ran using directives in a configuration file
specific to your environment: test, development, production (BTW, running tests in production is not recommended).  All attributes are configured inside a DuckTest.config block.

    # config/environments/test.rb  (development.rb, production.rb, etc.)
    DuckTest.config do
      runnable "**/*"
      watch "**/*"
    end

Watched files are broken down into two categories: runnable and non-runnable.

  - <b>runnable</b> files are test files such as (Test::Unit, RSpec, etc.) and you define them using {DuckTest::Config#runnable runnable}.
  - <b>non-runnable</b> files are anything except a runnable file and you define them using {DuckTest::Config#watch watch}.  Typically, all of the files under the app directory
    of a Rails application such as models, controllers, view, etc. are non-runnable files  The intent is that you can define non-runnable files that are watched and mapped to
    runnable files that are triggered when non-runnable files are changed.

<a name="watch_desc" />
To understand all of the moving parts, it is important to explain how files are watched.  The runnable and watch directives behave in the same manner.  In fact, runnable
is just a wrapper for the watch method that sets a couple of attributes for you prior to calling the watch method itself.  A {DuckTest::FrameWork::WatchConfig} object is
created for every runnable and watch directive in a config block and contains all of the attributes you specify within the block: pattern, filters, mappings, paths, etc.
Those objects exist for the lifetime of your Rails console session.

During startup, all of the watch config objects are passed to the current {DuckTest::FrameWork::Base framework} object and files are retrieved from the file system by
looping thru all of the watch config objects.  For each, Dir.glob is called to obtain a set of files as per the patterns you specify and you are allowed to use multiple.
Next, the included and excluded filters are applied to each directory and file individually.  Directories / files that pass the criteria are added to a "white list" while
the ones that fail are added to a "black list".

The purpose of the black and white lists is performance.  When a directory / file changes, the black list is searched and
if found the directory / file is ignored.  A good example of the use of black list would be temporary files created by your editor with the same name that are placed in the
same directory as the file you are editing.  No sense in running those files.  The purpose of the white list is performance as well.  If a directory / file is on the white
list, then, all of the information is already known, so, we can avoid having to process the file from scratch.  New directories / files are processed in the same manner as
when the framework session starts, so, all of the same rules apply.

## Load path
It is important to note that all of your test files and related files MUST BE visible to the Rails console.

The current version of DuckTest will add the test directory to config.autoload_paths of your Application object during startup.  The following code is pulled
directly from the DuckTest::Railtie

    config.before_configuration do |app|
      if Rails.env.eql?("test")
        app.config.autoload_paths += %W(#{Rails.root}/test)
      end
    end

Depending on your needs you may have to alter the load path so the tests can be run within the console.  One possible method is to edit config/application.rb
to alter the autoload path prior to it being frozen.  Bottom line, all that is required for tests to run is that they are visible on the load path.

<a name="base_directories"/>
## Base directories
DuckTest uses a root directory when looking for all files.  By default, {DuckTest::Config} will use Rails.root as it's own root directory.  In an attempt to help keep config files
from being complicated and messy, DuckTest employs a base directory for runnable and non-runnable files.

  - {DuckTest::ConfigHelper#runnable_basedir runnable_basedir} is a base directory that should be located directly off of the {DuckTest::ConfigHelper#root root} directory and
    is automagically factored in when searching for files that are runnable.

  - {DuckTest::ConfigHelper#watch_basedir watch_basedir} is a base directory that should be located directly off of the {DuckTest::ConfigHelper#root root} directory and
    is automagically factored in when searching for files that are non-runnable.

The main reason for the existence of the base directories is to help ease the pain of configuration by eliminating the need to include directory names in filter and mapping expressions.

For example:

      DuckTest.config do
        runnable "test**/*", included_dirs: /^test/unit/, excluded_dirs: [/^test/functional/, /^test/assets/, /.gitkeep$/, /kate-swp$/]
        watch "app**/*", included_dirs: /^app/models/, excluded_dirs: /^test/controllers/ do
          map /app/models/, /^book.rb/ do
            target /^test/unit/, /^book/
            target /^test/unit/, /^special_case/
          end
          map /app/models/, /^car.rb/ do
            target /^test/unit/, /^car/
            target /^test/unit/, /^special_case/
          end
        end
      end

      DuckTest.config do
        runnable_basedir :test
        watch_basedir :app
        runnable "**/*", included_dirs: /^unit/, excluded_dirs: [/^functional/, /^assets/, /.gitkeep$/, /kate-swp$/]
        watch "**/*", included_dirs: /^models/, excluded_dirs: /^/controllers/ do
          map /models/, /^book.rb/ do
            target /^unit/, /^book/
            target /^unit/, /^special_case/
          end
          map /models/, /^car.rb/ do
            target /^unit/, /^car/
            target /^unit/, /^special_case/
          end
        end
      end

runnable_basedir and watch_basedir attributes trickle down into all of runnable, watch, map blocks, however, you do have the option of overriding for a specific block by passing a value
to the block:

    watch "**/*", watch_basedir: :my_other_dir

A good way to think of the {DuckTest::Config#runnable} and {DuckTest::Config#watch} methods is we are using the standard Dir.glob method to retrieve a file set from disk and
using Regexp, String, Symbols, and Arrays or any combinations of the three to filter the file set via includes and excludes.  This should be more enough to satisfy any need.

# Filter sets

See {file:FILTERS.md} for information regarding the use of filtersets (included, included_dirs, excluded, excluded_dirs).

# Mapping non-runnable files to runnable files
DuckTest provides the ability to automagically execute runnable test files when non-runnable files change.  The mechanism to achieve this task is mapping.

    watch "**/*", excluded_dirs: /^assets/ do
      map /models/, /[a-z]/ do
        target /functional/, /[a-z]/
      end
    end

See {DuckTest::Config#map} for more information regarding mapping.


# Native file listeners
For better performance, DuckTest supports native file listeners for three platforms.  To use a native file listener, simply include it in your application Gemfile and run: bundle install
DuckTest will recognize that the native file listener is available and use it.

    # Linux
    linux gem 'rb-inotify'

    # Mac
    mac gem 'rb-fsevent'

    # windoze
    gem 'rb-fchange'

# Testing frameworks

Currently, DuckTest supports the following testing frameworks.  As time passes, I will add notes specific to each framework in this section.

## Testunit

## RSpec

# Choosing which testing framework to load
Duck Test supports multiple testing frameworks :testunit, :rspec, etc.  You have two options to choose which testing framework to load at startup.

- Config file

  Testing frameworks are defined per Rails environment via config/environments files respectively.  The following tell DuckTest to load :testunit testing framework
  when the rails console loads.

      DuckTest.config do
        default_framework :testunit
      end

- Command line

  You can override the default_framework setting via the command line in one of two ways:

    - Setting an environment variable and start the Rails console normally

          DUCK_TEST=my_framework rails c test

    - Use the ducktest executable.  Most Rails commands validate the arguments passed on the command line, so, custom arguments are not allowed using the standard Rails command.
      Therefore, ducktest is an executable that wraps the standard Rails command to start the console and allows you to pass extra arguments.  Simply pass the desired testing
      framework on the command line and the ducktest executable will grab the argument, then, load the standard Rails console as normal.

          ducktest c test my_framework

# Pre-load, Post-load, Pre-Run, Post-run
Test files are loaded and run within the context of a fork block.  Per testing framework, you can configure a block to execute at six points of the
execution of the tests.
  - pre_load - called just prior to loading the non-runnable and runnable test files from disk.
  - post_load - called just after loading the non-runnable and runnable test files from disk.
  - pre_run - called just prior to actually running the tests.
  - post_run - called just after running the tests.

In the following example, notice that all four blocks receive a reference to the {DuckTest::FrameWork::Base} object that triggered the block.  However,
two of the blocks have an extra argument named flag.  The extra flag is a Symbol (:non_runnable or :runnable) and indicates which files are about to
be loaded.  Non-runnable files ARE NOT loaded within the context of the fork block.  Runnable files ARE loaded within the context of the fork block.

      DuckTest.config do
        framework :rspec do
          pre_load do |framework, flag|
            # load some files, set some global stuff, etc.
          end
          post_load do |framework, flag|
            # clean up after loading, clear logs??, etc.
          end
          pre_run do |framework|
            # load some files, set some global stuff, etc.
          end
          post_run do |framework|
            # clean up after running
          end
        end
      end


# Running the debugger
Since we are loading and running tests directly in the Rails console, the debugger is available.  Pretty cool, eh?  As of this writing, only minimal testing
has been done using the debugger.  Feedback is definitely appreciated.

# Logging
DuckTest has an internal logger that writes to log/ducktest.logger.  The default log level is debug.  You can set the log level in a config block or via
the command in the console.

In a configuration block

      DuckTest.config do
        log_level :info
      end

or in the console

      irb(main):001:0> duck.loglevel :info

The supported debugging levels are: :debug, :info, :warn, :error, :fatal, and :unknown.  There is a method named console which will write message to
the console output stream.

      class MyTest < ActiveSupport::TestCase
        include DuckTest::LoggerHelper

        test "the truth" do
          ducklog.console "displayed to the Rails console"
          assert true
        end

      end

# Commands

TODO document the commands

# Why use the name Duck Test?
This stems from a habit I picked up years ago back in the days when I was doing DBase and Clipper programming for DOS.  I picked up the idea from one of my favorite
authors at the time (Rick Spence - or at least I think it was Rick).  Anyway, the idea is to basically sign your code by incorporating your initials
into library names or method calls.  That way, you know the origin of a piece of code at a glance.  The downside is that you definitely own it and
can't blame it on that guy that keeps beating you to the good doughnuts.  I hate that guy!!  The second reason is the gem name space is pretty full and there was a good
chance the name hasn't been taken.

# Copyright
Copyright (c) 2012 Jeff Duckett. See License.txt for details.

