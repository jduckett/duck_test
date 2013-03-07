require 'fileutils'

class TestFiles

  ##################################################################################
  # the base or root directory for the set of test directories / files
  def self.base_dir
    return "#{File.expand_path(File.dirname(__FILE__))}/testapp"
  end

  ##################################################################################
  # The actual set of test directories / files
  def self.files
    return [
      {dir: ["test"],                           files: ["test01.rb", "test02.rb", "test03.rb", "test04.rb"]},
      {dir: ["test", "unit"],                   files: ["truck_test.rb", "car_test.rb", "bike_test.rb"]},
      {dir: ["test", "unit", "sec"],            files: ["user_test.rb", "role_test.rb", "group_test.rb"]},
      {dir: ["test", "unit", "admin"],          files: ["admin_test.rb"]},
      {dir: ["test", "functional"],             files: ["truck_controller_test.rb", "car_controller_test.rb", "bike_controller_test.rb"]},
      {dir: ["test", "fixtures"],               files: ["books.yml"]},
      {dir: ["test", "integration"],            files: ["truckintegration_test.rb", "car_integration_test.rb", "bike_integration_test.rb"]},
      {dir: ["test", "performance"],            files: ["truck_performance_test.rb", "car_performance_test.rb", "bike_performance_test.rb"]},
      {dir: ["app"],                            files: ["app01.rb", "app02.rb", "app03.rb", "app04.rb"]},
      {dir: ["app", "controllers"],             files: ["truck_controller.rb", "car_controller.rb", "bike_controller.rb"]},
      {dir: ["app", "models"],                  files: ["truck.rb", "car.rb", "bike.rb"]},
      {dir: ["app", "views"],                   files: []},
      {dir: ["app", "views", "bikes"],          files: ["index.html.erb", "show.html.erb", "edit.html.erb", "new.html.erb"]},
      {dir: ["app", "views", "cars"],           files: ["index.html.erb", "show.html.erb", "edit.html.erb", "new.html.erb"]},
      {dir: ["app", "views", "trucks"],         files: ["index.html.erb", "show.html.erb", "edit.html.erb", "new.html.erb"]}
            ]
  end

  ##################################################################################
  # builds the entire directory / file structure in the form of a list.  each item is a full file test.
  def self.file_list
    list = []
    self.files.each do |item|
      item[:files].each {|file| list.push(File.join(self.base_dir, item[:dir], file))}
    end
    return list
  end

  ##################################################################################
  # removes all of the test directories / files
  def self.clean
    if File.exist?(self.base_dir)
      puts "Removing test files and directories..."
      FileUtils.rm_r self.base_dir
      puts "Done."
    else
      puts "Nothing to clean..."
    end
  end

  ##################################################################################
  # generates all of the test directories / files
  def self.setup
    unless defined?(@@setup_complete)
      self.clean
      self.dir_list.each {|dir| FileUtils.mkdir_p dir}
      FileUtils.touch self.file_list
      puts "\r\n\r\n"
      #puts self.file_list
      puts "\r\n\r\nThe above files have been created.\r\n\r\n"
      @@setup_complete = true
    end
  end

  ##################################################################################
  # similar to self.file_list, however, returns directories ONLY.  each item is a full file test.
  def self.dir_list
    list = []
    self.files.each do |item|
      list.push(File.join(self.base_dir, item[:dir]))
    end
    return list
  end

  ##################################################################################
  #   puts TestFiles.find_dirs(dir: :test, full: false)
  #   test
  #   test/unit
  #   test/unit/sec
  #   test/unit/admin
  #   test/functional
  #   test/fixtures
  #   test/integration
  #   test/performance
  #
  #   puts TestFiles.find_dirs(dir: :test, excluded: :unit, full: true)
  #   /alldata/rails/gems/duck_test/test/testdir/test
  #   /alldata/rails/gems/duck_test/test/testdir/test/unit/sec
  #   /alldata/rails/gems/duck_test/test/testdir/test/unit/admin
  #   /alldata/rails/gems/duck_test/test/testdir/test/functional
  #   /alldata/rails/gems/duck_test/test/testdir/test/fixtures
  #   /alldata/rails/gems/duck_test/test/testdir/test/integration
  #   /alldata/rails/gems/duck_test/test/testdir/test/performance
  #
  #   puts TestFiles.find_dirs(dir: :test, excluded: [[:unit, :sec]], full: true)
  #   /alldata/rails/gems/duck_test/test/testdir/test
  #   /alldata/rails/gems/duck_test/test/testdir/test/unit
  #   /alldata/rails/gems/duck_test/test/testdir/test/unit/admin
  #   /alldata/rails/gems/duck_test/test/testdir/test/functional
  #   /alldata/rails/gems/duck_test/test/testdir/test/fixtures
  #   /alldata/rails/gems/duck_test/test/testdir/test/integration
  #   /alldata/rails/gems/duck_test/test/testdir/test/performance
  #
  #   puts TestFiles.find_dirs(dir: :test, excluded: /^unit/, full: true)
  #   /alldata/rails/gems/duck_test/test/testdir/test
  #   /alldata/rails/gems/duck_test/test/testdir/test/functional
  #   /alldata/rails/gems/duck_test/test/testdir/test/fixtures
  #   /alldata/rails/gems/duck_test/test/testdir/test/integration
  #   /alldata/rails/gems/duck_test/test/testdir/test/performance
  #
  # options
  # dir - compared against the first item of dir: for each of self.files
  # excluded - directories to exclude from the result.  can be a single or an array of Symbols, Strings, Regexps
  # path - :full   returns the full file test including self.base_dir
  #      - :path   the directory path
  # type - :path   returns a full path test /alldata/rails/gems/duck_test/test
  #      - :array  returns the dir: array from the hash for the item
  #      - :hash   returns the dir: hash for the item
  def self.find_dirs(options = {})
    config = {dir: "", excluded: [], path: :path, type: :path}.merge(options)
    list = []
    excluded = config[:excluded].kind_of?(Symbol) || config[:excluded].kind_of?(String) || config[:excluded].kind_of?(Regexp) ? [config[:excluded]] : config[:excluded]
    config[:dir] = "all" if config[:dir].blank?

    config[:pattern] = config[:pattern].kind_of?(String) || config[:pattern].kind_of?(Symbol) || config[:pattern].kind_of?(Regexp) ? [config[:pattern]] : config[:pattern]
    config[:pattern] = config[:pattern].blank? ? [:all] : config[:pattern]
    config[:pattern].each_with_index {|item, index| config[:pattern][index] = item.to_s if item.kind_of?(Symbol)}

    self.files.each do |item|
      if item[:dir].first.eql?(config[:dir].to_s) || config[:dir].eql?("all")

        included = true

        path = item[:dir].dup
        path.shift
        path = path.join("/")

        excluded.each do |exp|

          if (exp.kind_of?(String) || exp.kind_of?(Symbol)) && path.eql?(exp.to_s)
            included = false
            break

          elsif exp.kind_of?(Array) && path.eql?(exp.join("/"))
            included = false
            break

          elsif exp.kind_of?(Regexp) && path =~ exp
            included = false
            break
            
          end

        end

        if included

          included = false
          if config[:pattern].length > 0 && config[:pattern].first.eql?("all")
            included = true
          else

            config[:pattern].each do |pattern|

              if pattern.kind_of?(String)
                if path.eql?(pattern)
                  included = true
                  break
                end

              elsif pattern.kind_of?(Regexp)
                if path =~ pattern
                  included = true
                  break
                end

              end

            end

          end

          if included
            if config[:type].eql?(:path)
              if config[:path].eql?(:full)
                list.push(File.join(self.base_dir, item[:dir]))
              else
                list.push(File.join(item[:dir]))
              end

            elsif config[:type].eql?(:array)
              list.push(item[:dir])

            elsif config[:type].eql?(:hash)
              list.push(item)

            end
          end

        end

      end
    end

    return list
  end

  ##################################################################################
  # first, calls self.find_dirs to get a set of directory hashes from self.files
  #
  #   puts TestFiles.find_files(dirs: {dir: :test, excluded: /^unit/}, pattern: /^bike/, path: :full)
  #   /alldata/rails/gems/duck_test/test/testdir/test/functional/bike_controller_test.rb
  #   /alldata/rails/gems/duck_test/test/testdir/test/integration/bike_integration_test.rb
  #   /alldata/rails/gems/duck_test/test/testdir/test/performance/bike_performance_test.rb
  #
  #   puts TestFiles.find_files(dirs: {dir: :test, excluded: /^unit/}, pattern: /^bike/, path: :path)
  #   test/functional/bike_controller_test.rb
  #   test/integration/bike_integration_test.rb
  #   test/performance/bike_performance_test.rb
  #
  #   puts TestFiles.find_files(dirs: {dir: :test, excluded: /^unit/}, pattern: /^bike/, path: :file)
  #   bike_controller_test.rb
  #   bike_integration_test.rb
  #   bike_performance_test.rb
  #
  # options
  # dirs:  {}  A hash containing all of the values usually passed to self.find_dirs
  # 
  # pattern - A set of patterns to compare against each file_test. can be a single or an array of Symbols, Strings, Regexps
  #           omit pattern or set it to :all to return all files.
  # path - :full   returns the full file test including self.base_dir
  #      - :path   the directory path
  #      - :file   the file_test (file_name) ONLY
  def self.find_files(options = {})
    config = {excluded: [], path: :path}.merge(options)
    dir_config = config.delete(:dirs)
    dir_config[:path] = :path
    dir_config[:type] = :hash
    list = []

    config[:pattern] = config[:pattern].kind_of?(String) || config[:pattern].kind_of?(Symbol) || config[:pattern].kind_of?(Regexp) ? [config[:pattern]] : config[:pattern]
    config[:pattern] = config[:pattern].blank? ? [:all] : config[:pattern]
    config[:pattern].each_with_index {|item, index| config[:pattern][index] = item.to_s if item.kind_of?(Symbol)}

    dirs = self.find_dirs(dir_config)
    dirs.each do |dir|

      dir[:files].each do |file_test|

        if config[:pattern].length > 0 && config[:pattern].first.eql?("all")
          if config[:path].eql?(:full)
            list.push(File.join(self.base_dir, dir[:dir], file_test))

          elsif config[:path].eql?(:path)
            list.push(File.join(dir[:dir], file_test))

          else
            list.push(file_test)

          end

        else
          config[:pattern].each do |pattern|

            if pattern.kind_of?(String)
              if file_test.eql?(pattern)
                if config[:path].eql?(:full)
                  list.push(File.join(self.base_dir, dir[:dir], file_test))

                elsif config[:path].eql?(:path)
                  list.push(File.join(dir[:dir], file_test))

                else
                  list.push(file_test)

                end
              end

            elsif pattern.kind_of?(Regexp)
              if file_test =~ pattern
                if config[:path].eql?(:full)
                  list.push(File.join(self.base_dir, dir[:dir], file_test))

                elsif config[:path].eql?(:path)
                  list.push(File.join(dir[:dir], file_test))

                else
                  list.push(file_test)

                end
              end

            end

          end
        end

      end
    end

    return list
  end

  ##################################################################################
  # searches self.files for a single file_test
  #
  #   puts TestFiles.file_test("truck_controller_test", path: :full)
  #   /alldata/rails/gems/duck_test/test/testdir/test/functional/truck_controller_test.rb
  #
  #   puts TestFiles.file_test("truck_controller_test", path: :path)
  #   test/functional/truck_controller_test.rb
  #
  #   puts TestFiles.file_test("truck_controller_test", path: :file)
  #   truck_controller_test.rb
  #
  # file_test - the file name to find
  # options
  # path - :full   returns the full file test including self.base_dir
  #      - :path   the directory path
  #      - :file   the file_test (file_name) ONLY
  # returns String
  def self.file_spec(file_test, options = {})
    config = {path: :full}.merge(options)
    value = ""

    files.each do |item|

      item[:files].each do |file_name|

        if file_name.eql?(file_test) || file_name =~ /#{file_test}.rb/

          if config[:path].eql?(:full)
            value = File.join(self.base_dir, item[:dir], file_name)

          elsif config[:path].eql?(:path)
            value = File.join(item[:dir], file_name)

          else
            value = file_name

          end

          break

        end

      end

    end

    return value
  end

  ##################################################################################
  # conveienence wrapper for find files that imposes :test as the directory
  def self.test_files(options = {})
    config = {}.merge(options)
    config[:dirs] = {} unless config[:dirs].kind_of?(Hash)
    config[:dirs][:dir] = :test if config[:dirs]
    return self.find_files(config)
  end

  ##################################################################################
  # conveienence wrapper for find files that imposes :app as the directory
  def self.app_files(dirs = [], options = {})
    config = {}.merge(options)
    config[:dirs] = {} unless config[:dirs].kind_of?(Hash)
    config[:dirs][:dir] = :app if config[:dirs]
    return self.find_files(config)
  end

  ##################################################################################
  def self.dir(pattern)
    list = []
    if pattern.kind_of?(String)
      list.push(File.join(self.base_dir, pattern))
    elsif pattern.kind_of?(Array)
      pattern.each do |item|
        list.push(File.join(self.base_dir, item))
      end
    end

    return Dir.glob(list)
  end

end



































