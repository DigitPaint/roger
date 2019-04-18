# Changelog

## Version 1.10.0
* Make release-copy command a configurable lambda and use xcopy on Windows by default

## Version 1.9.1
* Make Roger work on Windows (except the rsync finalizer)

## Version 1.9.0
* Render all *.erb files by default
* Update dependencies
* Rsync finalizer now uses `--delete`
* Removed hpricot dependency and URL relativizer (now lives in roger_url)relativizer gem)

## Version 1.8.0
* Roger Rack application now adheres to match/skip options. Pass them in the rogerfile as follows:
    ```
    roger.server do |s|
      s.application_options = { match: [], skip: [] }
    end
    ```

## Version 1.7.2
* Return from partials instead of rendering partial content as string. This allows us to have code in ruby blocks instead of just more ERB.

## Version 1.7.1
* Allow setting defaults per template extension.
* Minor fixes

## Version 1.7.0
* Finalizers and processors now use the same stack. This means you can run processors after certain finalizers
* Finalizers and processors now have exactly the same API
* Roger automatically detects free ports now. This can be disabled by passing `auto_port = false` to the server options ( or passing `--server:auto_port=false` on the commandline)
* Add support for using partials with directly passing locals. Instead of doing `partial "x", locals: {a: 1}` you can now do `partial "x", a: 1`. The old method still works and allows for setting other template options.
* Allow setting of a default layout by setting `roger.project.options[:renderer][:layout] = "the_default_layout_name"` in your `Rogerfile`. Or via commandline `--renderer:layout='bla'` if you must.
* Bug fixes:
    - Release will take the set `project.html_path` instead of hardcoded path
    - Fix issues with newer Thor versions
    - Add more code higiene
    - Don't fail if there is no Gemfile. This fixes the `roger generate new` command.

## Version 1.6.4
* Fix bug with block partials in layouts by correctly determine the current Tilt template we're rendering.

## Version 1.6.3
* Fix issue with `render_file` screwing up the current_template nesting stack.

## Version 1.6.2
* Allow for tempalte recursion for up to 10 levels.
* Fix issue with missing partials that would screw up the current_template nesting stack.

## Version 1.6.1
* No longer process partials in html directory on release.

## Version 1.6.0
* Change the way template resolving works so if you have a file and directory with the same basename it will prefer to use the file instead of looking for name/index.xyz
* Add `content_for?(:xyz)` helper so you can check if a `content_for` block exists in templates.
* Fix bug with resolving of trailing slashes.

## Version 1.5.1
* Add MockShell object to stub out shell interactions. MockShell is also used by MockProject. This means all tests are silent on STDOUT/STDERR now.

## Version 1.5.0
* Roger won't be tested on Ruby 1.9.x anymore
* The way we render templates has been revamped. It is now possible to have multi-pass templates so you can do `.md.erb` which will first be processed by `erb` and then by the `md` tilt template handler.
* The way templates are searched has changed to be more predictable. You may notice the change when you have the same filenames with different extensions.
* You can now use local partials by just using an underscore as prefix. So `<%= partial('bla') %>` will look for `_bla.*` relative to the current template first and `bla.*` in the partials directory second (current behaviour).
* Template recursion will be detected and prevented instead of giving a stack overflow.
* Add `render_file` method to renderer and as helper so you can render any template on disk.
* Minor doc improvements

## Version 1.4.6
* Allow setting target_path in dir finalizer
* Always create target_paths if they don't exist

## Version 1.4.5
* Allow setting target_path in zip finalizer

## Version 1.4.4
* Let MockProject require Project so it always works

## Version 1.4.3
* "test_construct" is now a regular dependency so you can use the MockProject / MockRelease in your own tests.

## Version 1.4.2
* Fix where release required CLI and in turn bundler would get triggered. CLI is the entrypoint and should never be required in a deeper level.

## Version 1.4.1
* Minor fix for release on Linux when using the default `cp -RL` to copy html to build.

## Version 1.4.0
* Rename Mockupfile to Rogerfile
* Remove the deprecated `Roger::Extractor` (use `Roger::Template` instead)
* Add support for template helpers through `Roger::Template.register MyHelpersModule`
* Add more documentation on templating
* Comment method from Rogerfile will no longer add ! to js/css comments
* Heavily increase test coverage

## Version 1.3.4
* Require the correct "English" module (with capital E) for $CHILD_STATUS

## Version 1.3.3
* Add tests for rsync finalizer and get_files
* Get files now only matches files, not directories
* Rsync finalizer works with $CHILD_STATUS

## Version 1.3.2
* Fix for missing variable in zip finalizer
* Fix passing options within Mockup

## Version 1.3.1
This is a dud. It's identical to 1.3.1. Don't use.

## Version 1.3.0
* Add fixed SCM for testing (you can set a fixed version number)
* Fix for missing variable in UrlRelativizer
* Add Mocks for Project and Release to use in testing (can also be used by external plugins)
* Refactoring of tests
* Add CodeClimate (https://codeclimate.com/github/DigitPaint/roger)

## Version 1.2.2
* Fix missing variables in release

## Version 1.2.1
* Fix missing env (https://github.com/DigitPaint/roger/issues/24)

## Version 1.2.0
* `roger.project` is now always in `env` when running as a project or as a release. Use this in favor of `env["MOCKUP_PROJECT"]`
* All Roger code now is linted by Rubocop. More tests have been added and more documentation as well. Still not everything may have been covered by the tests.


## Version 1.1.3
* Add `--version` flag so we can ask what version of Roger we're running.

## Version 1.1.2

* Fix issue where nested `content_for` statements or partials with blocks within a `content_for` block would yield multiple times.

## Version 1.1.1

* Better compatiblity with the release as `build` is a relative path it will give sometimes weird issues. This has now been resolved.

## Version 1.1.0

* Allow passing of options to release, test and server from Mockupfile
* Add option to make blank releases by passing `blank: true`; a blank release will not automatically add default processors and finalizers. This is a non-breaking change, the default is blank: false
* Add project.mode so we can infer what mode we're in (:test, :release, :server) when running processors, middleware, tests, ets.
* Release now by default takes project path as root instead of PWD. If you rely on this behaviour you may want to pass your own path definitions in mockup.release(....).

## Version 1.0.1

* Release copy command is now configurable by passing :cp configuration option to the mockup.release command in the mockup file. By default the release now uses system cp instead of fileutils cp so we can follow symlinks (you don't want symlinks in your release). If you want the old behaviour you have to pass {cp: nil}.

## Version 1.0.0

There should be no breaking changes between 0.13.0 and 1.0.0

* Add support for generators giving themselves names through `self.register`
* Add support for setting hostname to listen to
* Default listening to 0.0.0.0 instead of localhost only
* Added more unittests for different CLI options
* Minor fixes

## Version 0.13.0
*Attention* This is the last call version before 1.0.0 (5 years in sub 1.0.0 is more than enough)

There should be no breaking changes between 0.12.5 and 0.13.0

* Added `test` command infrastructure inlcuding tests
* Remove W3C Validator, it is now available as a separate gem (`roger_w3cvalidator`)
* Minor internal refactorings and library updates (mainly Thor and Test-Unit)

## Version 0.12.5
* Fix github pages finalizer to work if the Dir finalizer is loaded as well
* Run relativizer as the last thing before you finalize as to fix resolving issues with generated files
* Minor coding style issues

## Version 0.12.4
* Change upload prompt to conform to the [y/N] convention
* Fix git SCM to properly shell escape arguments so it works with special chars in paths

## Version 0.12.3
* Allow release cleaner to work with arrays of globs/paths

## Version 0.12.2
* Add redcarpet as a dependency so markdown processing always works

## Version 0.12.1
* Fix bug when passing ENV to templates and added regression test

## Version 0.12.0
* Allow passing blocks to partials. Keep in mind that you'll need to use the `<% ... %>` form when using blocks.

## Version 0.11.0
* You can now register release processors and finalizers with a name and use them by name (call `Roger::Release::Finalizers.register(:name, Finalizer)` or `Roger::Release::Processors.register(:name, Processor)`)
* Generators now need to be registered on `Roger::Generators` instead of `Roger::Generators::Base`
* Minor bugfixes

## Version 0.10.0
* Welcome **Roger**
* Removed requirejs, sass and yuicompressor processors in favour of separate gems
* Removed legacy templates using `<!-- [START:...] -->` partials (still available in separate gem)

## Version 0.9.0
* More documentation!
* More tests! (and CI!)
* Thor and Tilt updates
* Add possibility to load external generators from gems (with the `Roger::Generators::Base.register` method)
* Partials now automatically prefer templates of the same extension as the parent
* ERB Templates now support `content_for(:name) do ... end` blocks which can be yielded by `:name` in the layout
* Multiple load paths for partials are now supported
* Minor changes and fixes
* First preparations for version 1.0.0. which will be called **Roger**

## Version 0.8.4
* Fix requirejs processor to clean up the correct paths
* Allow typing of Y to rsync instead of full "yes"

## Version 0.8.3
* Make the url relativizer respect :skip parameter

## Version 0.8.2
* If bundler is installed we're running Bundler.require automatically.

## Version 0.8.1
* Don't crash on non-existent partials/layouts path
* Add more logging in verbose mode when extracting mockup
* Fix the passing of env options to mockup release processor

## Version 0.8.0
* Set content type header in response when rendering templates
* Add option to prompt user before performing rsync finalizer (defaults to true)
* Fix zip finalizer to use options[:zip] in actuall executed command too
* Logger now outputs color and has support for warning messages
* Mockup templating is now fully handled with Tilt
* Mockup extraction and URL relativization etc. for release are now done in their respective processors (will be added automatically if you haven't added them yourself.) This gives a fine-grained control over the point in time when these processors are ran.
* Add a testproject to the repository
* Add support for layouts
* Add a `git_branch` finalizer that allows us to release to a branch on a repository (this makes it easy to release github pages)
* Allow requirejs processor to work wih single files as well
* Expose server options to mockup so you can configure a https server if you want
* Minor fixes

## Version 0.7.4
* Allow for underscores in .scss files when releasing

## Version 0.7.3
* Set a sensible `load_path` for sass in release mode (defaults to `build_path + "stylesheets"`)
* Also automatically require the rsync finalizers

## Version 0.7.2
* Add zip finalizers
* Instead of complaining about existing build path, just clean it up
* Instead of complaining about unexisting target path, just create it
* Automatically require all built-in procssors

## Version 0.7.1
* Pass target_file to the ERBTemplate to files with erb errors
* Fix env["MOCKUP_PROJECT"] setting in extractor

## Version 0.7.0
* Replace --quiet with -s in as it's no longer supported in newer GIT versions
* Add support for ENV passing to the partials
* Add support for single file processing and env passing in the extractor (release)
* Refactor path and url resolving
* Allow `.html` files to be processed by ERB (both in release and serve)
* Pass "MOCKUP_PROJECT" variable to env (both in release and serve)

## Version 0.6.5
* Allow disabling of URL relativizing in the extractor with `release.extract :url_relativize => false`
* Add missing Hpricot dependency to gem

## Version 0.6.4
* Add RsyncFinalizer to automatically upload your mockup

## Version 0.6.3
* Add license to gemspec
* Fix default_template in gem
* Add option to allow for resolving urls in custom attributes in the extractor (via `release.extract(options_hash)`)
* Add more unified interface to finalizers and processors
* Fix error if node can't be found in Processors::Requirejs

## Version 0.6.2
* Improved cleaner with more robust tests

## Version 0.6.1
* Correctly pass file and linenumber to Mockupfile evaluation
* Add the tilt gem as a requirement (needed for injectors in release)
* Make the cleaner also remove directories, also make it more safe (it will never delete stuff above the build_path)

## Version 0.6.0
* Pass command line options to underlying objets
* Update docs
* The different Processors, injections and cleanups are run in order as specified. Finalizers will always be run last in their own order.
* Replace CLI "generate" command with "new" subcommand and add support for remote git skeletons based on Thor templating.
* Add most simple mockup directory as default_template
* Requirejs processor updated so it will search for a global r.js command, a local npm r.js command and a vendored r.js command
* Minor fixes and changes
