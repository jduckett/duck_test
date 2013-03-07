#require "bundler/gem_tasks"
#$:.unshift File.expand_path("lib")

#import "lib/tasks/gem_tasks.rake"
#import "lib/tasks/duck_tests.rake"

# encoding: UTF-8
require "bundler/gem_tasks"
require 'rake/testtask'

desc "Run all tests"
task :default => :test

desc "Run all tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
