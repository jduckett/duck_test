DevCom::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  DuckTest.config do

#     default_framework :rspec
#     autorun false

    excluded [/.gitkeep$/, /kate-swp$/, /.yml$/, /spec_helper/, /^.goutputstream/]
    excluded_dirs [/^assets/, /^fixtures/]

    watch_basedir :app

    runnable "**/*"
    watch "**/*" do
      non_loadable [/.erb$/]
      standard_maps

      #map :all, :all do
        #target /^functional/, :all do
          #match do |target, source|
            #buffer = source[:sub_directory].split("/")
            #buffer = buffer.pop
            ##buffer = buffer.slice(0, buffer.length - 1)
            
            #target[:file_name] =~ /#{buffer}_controller_test/ ? true : false
            ##puts "buffer: #{buffer}"
            ##puts "================================="
            ##puts "target: #{target[:file_name]}"
            ##puts "source sub_directory: #{source[:sub_directory]}"
            ##puts "source     file_name: #{source[:file_name]}"
            ##sub_directory_match?(target[:sub_directory]) && file_name_match?(target[:file_name], source[:file_name]) ? true : false
            ##false
          #end
        #end
      #end

    end

    #framework :rspec do
      #pre_load do |framework|
##         puts "===================== pre_load block"
##         puts "object: #{framework.class.name}"
      #end
      #pre_run do |framework|
##         puts "===================== pre_run block"
##         puts "object: #{framework.class.name}"
      #end
      #post_load do |framework|
##         puts "===================== post_load block"
##         puts "object: #{framework.class.name}"
      #end
      #post_run do |framework|
##         puts "===================== post_run block"
##         puts "object: #{framework.class.name}"
      #end
      #runnable_basedir :spec
      #runnable "**/*" #, excluded: [/.gitkeep$/, /kate-swp$/, /.yml$/, /spec_helper/]
      #watch "**/*" do
        #standard_maps
      #end

    #end

#     runnable_basedir :spec
#     watch_basedir :app

# #     runnable "**/*"
# #     watch "**/*" do
# # #       map do
# # #         target :all do
# # #           file_name do |value, cargo|
# # #             value =~ /#{File.basename(cargo, ".rb")}_test.rb/ ? true : false
# # #           end
# # #         end
# # #       end
# # 
# # #       standard_map
# # 
# # #       map do
# # #         target :all do
# # #           file_name {|value, cargo| value =~ /#{File.basename(cargo, ".rb")}_test.rb/}
# # #         end
# # #       end
# # 
# # 
# # # 
# # #       puts ".........>"
# # #       puts x
# # 
# # #       map /^models/, /^book/ do
# # #         target /^unit/, /book_test/
# # #         target /^functional/, /books_controller_test/
# # #       end
# # 
# #     end
    
  end

end
