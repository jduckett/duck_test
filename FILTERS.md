# Filter sets
Each runnable and watch configuration includes a {DuckTest::FrameWork::FilterSet} used to exclude or include directories and files from the file set.  Filter sets employ four attributes
to fine tune which files are actually watched.  The attributes are: included, included_dirs, excluded, and excluded_dirs.
All four attributes accept a single Regexp, an array of Regexps, or a single special Symbol named :all which tells the filter set to simply pass the evaluation of a directory or file as true.

Let's say your favorite editor creates temp files in the same directory as your test file using the same name with a different extension to keep it hidden or something along those lines.  Normally,
that file would be included in the file set to run due to the fact that we selected everything using \*\*/*.  It could get confusing as to what test actually ran if temporary files are allowed to
run.  So, you exclude them from the runnable and non-runnable list via an exluded filter.

    # exclude temp files and git files from being included in the returned file set.
    runnable "**/*", excluded_dirs: [/.gitkeep$/, /kate-swp$/]

As described {file:README.md#watch_desc here}, filters are applied individually to each file in a file set by {DuckTest::FrameWork::FileManager#watchable?}

Directories and files have separate attributes:

  - excluded: Evaluated against a file name ONLY.
  - excluded_dirs: Evaluated against a sub-directory minus the root and basedir.

        if the root path is: "/home/my_home/my_app"
        and the basedir path is: "test"
        and the sub-directory path is: "/home/my_home/my_app/test/unit/security"
        then: "/home/my_home/my_app/test" is removed from the sub-directory path
        and "unit/security" is compared against the included_dirs Regexp.

  - included: Evaluated against a file name ONLY.
  - included_dirs: Follows the same rules as excluded_dirs

The logic for processing a directory or file is very similar and very simple:

  - <b>Directories</b>

        Determine if the directory has been explicitly excluded.

        if the expression for excluded_dirs exists and the directory matches the expression, then, the directory is explicitly excluded and not watchable.

        unless the directory has been explicitly excluded

          if the expression for included_dirs exists

            if the directory matches the expression, then, the directory is explicitly excluded and not watchable.

          otherwise, the directory is watchable

  - <b>Files</b>

        Determine if the file has been explicitly excluded.

        if the expression for excluded_dirs exists and the file matches the expression, then, the file is explicitly excluded and not watchable.

        unless the file has been explicitly excluded

          if the expression for included_dirs exists

            if the file matches the expression, then, the file is explicitly excluded and not watchable.

          otherwise, the file is watchable

Also, setting any one of the four excluded / included attributes to :all will result in an evaluation of true.

    # watch everything
    watch "**/*"

    # watch all files that begin with bike
    watch "**/*", /^bike/

    # watch all files that are bikes, cars, or trucks that are in the controllers directory ONLY
    watch "**/*", included: [/^bike/, /^car/, /^truck/], included_dirs: /controllers/

    # one note about watch method, the second argument is implied to be the included attribute
    # watch all files that are bikes, cars, or trucks that are not in the controllers directory
    watch "**/*", [/^bike/, /^car/, /^truck/], excluded_dirs: /controllers/

    # eqivalent to the above, except, explicitly telling it included attribute
    watch "**/*", included: [/^bike/, /^car/, /^truck/], excluded_dirs: /controllers/

You have the option of setting default excluded / included attributes.  The default values are passed to runnable and watch blocks and used as default
values for each block, however, you can override those values with arguments to each method or within the block.

    DuckTest.config do

      excluded [/.tmp$/, /.yml$/]

      # uses the defaults
      runnable "**/*"
      watch "**/*"

      # override with arguments
      watch "**/*", excluded: [/.txt/]

      # override within the block
      watch "**/*" do
        excluded [/.rb~$/, /.kate-tmp$/]
      end

    end


















