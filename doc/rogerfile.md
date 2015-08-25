# Rogerfile

The rogerfile is where all the project configuration for releasing, serving etc. happens.

## Example

```ruby

# Some SASS defaults
Sass::Plugin.options[:style] = :expanded
Sass::Plugin.options[:template_location] = "./html/stylesheets"
Sass::Plugin.options[:css_location] = "./html/stylesheets"

# Set verbosity to true (you can also pass --verbose to roger)
# roger.project.options[:verbose] = true

# These are defaults, but can be set here
# roger.project.html_path = roger.project.path + "html"
# roger.project.partial_path = roger.project.path + "partials"

# Server is a regular Rack interface.
roger.serve do |server|
  server.use :sass
end

# Define tests
roger.test do |t|
  t.use :jshint
end

roger.release do |release|

  # You can add global guards these wele stop the release process immediately
  # if they are not fullfilled.
  #
  # required: parameter is optional and is true by default. If it's not true
  # the guard is not required. Checks will still run. This is mostly useful in 
  # situations where the guard output is needed in a block.
  release.guard :tests, required: true

  # Some more guards
  release.guard :bower_dependencies
  release.guard :npm_dependencies
  
  # The variables below can be used anywhere in this section
  release.target_path # The target path where releases are put
  release.build_path # The path where the release gets built
  release.source_path # The source for this mockup

  # Get git version, these variables can be used anywhere in this section
  release.scm.previous # Get the previous version SCM op (looks for tags)
  release.scm.version # Get the git version
  release.scm.date # Get the git date

  # Extract project (this is optional)
  # release.use :mockup

  # Create custom banner
  #
  # The default banner looks like this:
  #
  # =======================
  # = Version : v1.0.0    =
  # = Date : 2012-06-20   =
  # =======================
  release.banner do
    "bla bla bla"
  end

  # Sassify CSS (this are the defaults too), all options except form :match and :skip are passed to Sass.compile_file
  # release.use :sass, :match => ["stylesheets/**/*.scss"], :skip => [/_.*\.scss\Z/], :style => :expanded
  # The previous statement is the same as:
  release.use :sass

  # Run requirejs optimizer
  # release.use :requirejs, {
  #     :build_files => {"javascripts/site.build.js" => "javascripts"},
  #     :rjs => release.source_path + "../vendor/requirejs/r.js",
  #     :node => "node"
  #   }
  release.use :requirejs

  # Minify, will not minify anything above the :delimiter
  # release.use :yuicompressor, {
  #   :match => ["**/*.{css,js}"],
  #   :skip =>  [/javascripts\/vendor\/.*\.js\Z/, /_doc\/.*/],
  #   :delimiter => Regexp.escape("/* -------------------------------------------------------------------------------- */")
  # }
  # The previous statement is the same as:
  release.use :yuicompressor

  # Inject VERSION / DATE (i.e. in TOC)
  r.inject({ "[VERSION]" => release.scm.version, "[DATE]" => release.scm.date.strftime("%Y-%m-%d") }, into: %w(_doc/toc.html))

  # Inject Banners on everything matching the regexp in all .css files
  # The banner will be commented as CSS.
  release.inject({ /\/\*\s*\[BANNER\]\s*\*\// => r.banner(comment: :css) }, into: %w(**/*.css))

  # Inject CHANGELOG
  release.inject({ "[CHANGELOG]" => { file: "../CHANGELOG", processor: "md" } }, into: %w(_doc/changelog.html))

  # Inject NOTES
  release.inject({ "[NOTES]" => { file: "../NOTES.md", processor: "md" } }, into: %w(_doc/notes.html))

  # Cleanup on the build
  release.cleanup "**/.DS_Store"

  # Finalize the release
  # This is the default finalizer so not required
  # release.finalize :dir

  # Let's add a more complicated guard with a block
  # This type of guard will only guard the block not the whole
  # release process.

  # The guard below will check if the commandline flag `--skip-upload` is set
  # the block will run (the guard is satisfied) if the `--skip-upload` flag is NOT present
  release.guard :commandline_flag, flag: "skip-upload", satisfy_if: false do
    release.finalize :rsync, :host => "mywebhost", :username => "myuser", :remote_path => "www"
  end

  # This guard will check for the `--always-upload` flag. It will run the
  # inner block regardless of it's outcome. We can however use the guard to pass
  # info from the guard to the block.I 
  r.guard :commandline_flag, flag: "always-upload", required: false do |guard|
    release.finalize :rsync, :host => "mywebhost", :username => "myuser", :remote_path => "www", :ask => !guard.flag
  end 

end
```
