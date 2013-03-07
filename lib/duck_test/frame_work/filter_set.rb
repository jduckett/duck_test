module DuckTest
  module FrameWork

    # Data and methods that are used to filter directories and files.
    class FilterSet
      include LoggerHelper

      attr_accessor :included
      attr_accessor :included_dirs
      attr_accessor :excluded
      attr_accessor :excluded_dirs
      attr_accessor :non_loadable

      ##################################################################################
      # Initialize a new FilterSet
      # @return [FilterSet]
      def initialize(options = {})
        super()

        self.included = options[:included]
        self.included_dirs = options[:included_dirs]
        self.excluded = options[:excluded]
        self.excluded_dirs = options[:excluded_dirs]
        self.non_loadable = options[:non_loadable]

        return self
      end

      ##################################################################################
      # @note You can pass a Symbol named :all instead of a Regexp and the method will always return true.  This provides the ability to specify "all" files as part of a filter.
      # Compares a file_spec against an array of {http://www.ruby-doc.org/core-1.9.3/Regexp.html Regexp's} (filters).
      #
      #     match_filters?("test.rb", /^book/)               # => false
      #
      #     match_filters?("test.rb", [/^book/])             # => false
      #
      #     match_filters?("test.rb", [/^book/, /^test/])    # => true
      #
      #     match_filters?("test.rb", :all)                  # => true
      #
      #     match_filters?("test.rb", [:all])                # => true
      #
      # @param [String] file_spec    A file name that adheres to {http://ruby-doc.org/core-1.9.3/File.html#method-c-basename File.basename}.
      # @param [Array] filters       An Array of {http://www.ruby-doc.org/core-1.9.3/Regexp.html Regexp's}.  Each Regexp is compared against file_spec.
      #                              The first Regexp that matches file_spec wins and returns true, otherwise, this method returns false.
      #                              Also, you can pass an Array with a single Symbol named :all and match_filters? will always return true.
      # @param [String] subdirectory If file_spec is a directory, then, subdirectory will be used during the evaluations instead of file_spec.
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def match_filters?(file_spec = nil, filters = nil, subdirectory = nil)

        begin

          unless file_spec.blank? || filters.blank?

            ducklog.system %(FilterSet.match_filters?(#{file_spec}, #{filters}, #{subdirectory}))

            filters = filters.kind_of?(Array) ? filters : [filters]
            subdirectory = subdirectory.blank? ? "" : subdirectory

            filters.each do |expression|

              if expression.kind_of?(Symbol) && expression.eql?(:all)
                ducklog.system "returning true due to :all flag"
                return true

              elsif expression.kind_of?(Regexp)

                if File.directory?(file_spec)

                  # blank subdirectory is allowed, because, we might be comparing against a
                  # watch root directory.
                  if subdirectory.blank?
                    return true

                  elsif subdirectory.match(expression)
                    ducklog.system "returning true due to Regexp MATCH !!!!"
                    return true

                  end

                elsif File.basename(file_spec).match(expression)
                  ducklog.system "returning true due to Regexp MATCH !!!!"
                  return true

                end
              end
            end
          end

        rescue Exception => e
          ducklog.exception e
        end

        ducklog.system "FilterSet.match_filters?() returning false"

        return false
      end

      ##################################################################################
      # Conveinence method that calls {FilterSet#match_filters? match_filters?} with the current value of {FilterSet#included included}
      # - In this context, file_spec cannot be blank.
      # - Will return true if self.included array is nil or empty.
      # @param [String] file_spec See {FilterSet#match_filters? match_filters?}
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def included?(file_spec)
        ducklog.system %(FilterSet.included?(#{file_spec}, #{self.included}))
        if file_spec.blank?
          return false

        elsif self.has_included?
          return self.match_filters?(file_spec, self.included)

        else
          return true

        end
      end

      ##################################################################################
      # Conveinence method that determines if an {FilterSet#included included} filter exists.
      # @return [Boolean] Returns true if the {FilterSet#included included} filters exists, otherwise, false.
      def has_included?
        return self.included.blank? ? false : true
      end

      ##################################################################################
      # Conveinence method that calls {FilterSet#match_filters? match_filters?} with the current value of {FilterSet#included_dirs included_dirs}
      # - In this context, file_spec cannot be blank.
      # - In this context, subdirectory CAN BE blank.
      # - Will return true if self.included_dirs array is nil or empty.
      # @param [String] file_spec    See {FilterSet#match_filters? match_filters?}
      # @param [String] subdirectory Subdirectory is any directory directly off of the watch root directory.  Subdirectory CAN BE blank.
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def included_dirs?(file_spec, subdirectory)
        ducklog.system %(FilterSet.included?(#{file_spec}, #{self.included}, #{subdirectory}))
        if file_spec.blank?
          return false

        elsif self.has_included_dirs?
          return self.match_filters?(file_spec, self.included_dirs, subdirectory)

        else
          return true

        end
      end

      ##################################################################################
      # Conveinence method that determines if an {FilterSet#included_dirs included_dirs} filter exists.
      # @return [Boolean] Returns true if the {FilterSet#included_dirs included_dirs} filters exists, otherwise, false.
      def has_included_dirs?
        return self.included_dirs.blank? ? false : true
      end

      ##################################################################################
      # Conveinence method that calls {FilterSet#match_filters? match_filters?} with the current value of {FilterSet#excluded excluded}
      # - In this context, file_spec cannot be blank.
      # - Will return true if self.excluded array is nil or empty.
      # @param [String] file_spec See {FilterSet#match_filters? match_filters?}
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def excluded?(file_spec)
        ducklog.system %(FilterSet.excluded?(#{file_spec}, #{self.excluded}))
        if file_spec.blank?
          return false

        else
          return self.match_filters?(file_spec, self.excluded)

        end
      end

      ##################################################################################
      # Conveinence method that determines if an {FilterSet#excluded excluded} filter exists.
      # @return [Boolean] Returns true if the {FilterSet#excluded excluded} filters exists, otherwise, false.
      def has_excluded?
        return self.excluded.blank? ? false : true
      end

      ##################################################################################
      # Conveinence method that calls {FilterSet#match_filters? match_filters?} with the current value of {FilterSet#excluded_dirs excluded_dirs}
      # - In this context, file_spec cannot be blank.
      # - In this context, subdirectory CAN BE blank.
      # - Will return true if self.excluded_dirs array is nil or empty.
      # @param [String] file_spec    See {FilterSet#match_filters? match_filters?}
      # @param [String] subdirectory Subdirectory is any directory directly off of the watch root directory.  Subdirectory CAN BE blank.
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def excluded_dirs?(file_spec, subdirectory)
        ducklog.system %(FilterSet.excluded_dirs?(#{file_spec}, #{self.excluded_dirs}, #{subdirectory}))
        if file_spec.blank?
          return false

        else
          return self.match_filters?(file_spec, self.excluded_dirs, subdirectory)

        end
      end

      ##################################################################################
      # Conveinence method that determines if an {FilterSet#excluded_dirs excluded_dirs} filter exists.
      # @return [Boolean] Returns true if the {FilterSet#excluded_dirs excluded_dirs} filters exists, otherwise, false.
      def has_excluded_dirs?
        return self.excluded_dirs.blank? ? false : true
      end

      ##################################################################################
      # Conveinence method that calls {FilterSet#match_filters? match_filters?} with the current value of {FilterSet#non_loadable non_loadable}
      # - In this context, file_spec cannot be blank.
      # - In this context, subdirectory CAN BE blank.
      # - Will return true if self.non_loadable array is nil or empty.
      # @param [String] file_spec    See {FilterSet#match_filters? match_filters?}
      # @param [String] subdirectory Subdirectory is any directory directly off of the watch root directory.  Subdirectory CAN BE blank.
      # @return [Boolean] Returns true if a match is found, otherwise, false
      def non_loadable?(file_spec, subdirectory)
        ducklog.system %(FilterSet.non_loadable?(#{file_spec}, #{self.non_loadable}, #{subdirectory}))
        if file_spec.blank?
          return false

        else
          return self.match_filters?(file_spec, self.non_loadable, subdirectory)

        end
      end

      ##################################################################################
      # Conveinence method that determines if an {FilterSet#non_loadable non_loadable} filter exists.
      # @return [Boolean] Returns true if the {FilterSet#non_loadable non_loadable} filters exists, otherwise, false.
      def has_non_loadable?
        return self.non_loadable.blank? ? false : true
      end

    end
  end
end
