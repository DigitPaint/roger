require File.dirname(__FILE__) + "/cli"
require File.dirname(__FILE__) + "/helpers/get_callable"
require File.dirname(__FILE__) + "/helpers/get_files"
require File.dirname(__FILE__) + "/helpers/logging"
require File.dirname(__FILE__) + "/helpers/prompt"

require "shellwords"

module Roger
  # The release runner
  class Release
    include Roger::Helpers::Logging
    include Roger::Helpers::GetFiles
    include Roger::Helpers::Prompt

    attr_reader :config, :project

    attr_reader :finalizers, :stack

    class << self
     include Roger::Helpers::GetCallable

     def default_stack
       []
     end

     def default_finalizers
       [[get_callable(:dir, Roger::Release::Finalizers.map), {}]]
     end
    end

    # @option config [:git, :fixed] :scm The SCM to use (default = :git)
    # @option config [String, Pathname] :target_path The path/directory to put the release into
    # @option config [String, Pathname]:build_path Temporary path used to build the release
    # @option config [Boolean] :cleanup_build Wether or not to remove the build_path after we're
    #   done (default = true)
    # @option config [Array,String, nil] :cp CP command to use; Array will be escaped with
    #   Shellwords. Pass nil to get native Ruby CP. (default = ["cp", "-RL"])
    # @option config [Boolean] :blank Keeps the release clean, don't automatically add any
    #   processors or finalizers (default = false)
    def initialize(project, config = {})
      real_project_path = project.path.realpath
      defaults = {
        scm: :git,
        source_path: real_project_path + "html",
        target_path: real_project_path + "releases",
        build_path: real_project_path + "build",
        cp: ["cp", "-RL"],
        blank: false,
        cleanup_build: true
      }

      @config = {}.update(defaults).update(config)

      @project = project
      @stack = []
      @finalizers = []
    end

    # Accessor for target_path
    # The target_path is the path where the finalizers will put the release
    #
    # @return Pathname the target_path
    def target_path
      Pathname.new(config[:target_path])
    end

    # Accessor for build_path
    # The build_path is a temporary directory where the release will be built
    #
    # @return Pathname the build_path
    def build_path
      Pathname.new(config[:build_path])
    end

    # Accessor for source_path
    # The source path is the root of the project
    #
    # @return Pathname the source_path
    def source_path
      Pathname.new(config[:source_path])
    end

    # Get the current SCM object
    def scm(force = false)
      return @_scm if @_scm && !force

      case config[:scm]
      when :git
        @_scm = Release::Scm::Git.new(path: source_path)
      when :fixed
        @_scm = Release::Scm::Fixed.new
      else
        fail "Unknown SCM #{options[:scm].inspect}"
      end
    end

    # Inject variables into files with an optional filter
    #
    # @examples
    #   release.inject({"VERSION" => release.version, "DATE" => release.date},
    #     :into => %w{_doc/toc.html})
    #   release.inject({"CHANGELOG" => {:file => "", :filter => BlueCloth}},
    #     :into => %w{_doc/changelog.html})
    def inject(variables, options)
      @stack << Injector.new(variables, options)
    end

    # Use a certain pre-processor
    #
    # @examples
    #   release.use :sprockets, sprockets_config
    def use(processor, options = {})
      @stack << [self.class.get_callable(processor, Roger::Release::Processors.map), options]
    end

    # Write out the whole release into a directory, zip file or anything you can imagine
    # #finalize can be called multiple times, it just will run all of them.
    #
    # The default finalizer is :dir
    #
    # @param [Symbol, Proc] Finalizer to use
    #
    # @examples
    #   release.finalize :zip
    def finalize(finalizer, options = {})
      @finalizers << [self.class.get_callable(finalizer, Roger::Release::Finalizers.map), options]
    end

    # Files to clean up in the build directory just before finalization happens
    #
    # @param [String] Pattern to glob within build directory
    #
    # @examples
    #   release.cleanup "**/.DS_Store"
    def cleanup(pattern)
      @stack << Cleaner.new(pattern)
    end

    # Generates a banner if a block is given, or returns the currently set banner.
    # It automatically takes care of adding comment marks around the banner.
    #
    # The default banner looks like this:
    #
    # =======================
    # = Version : v1.0.0    =
    # = Date : 2012-06-20   =
    # =======================
    #
    #
    # @option options [:css,:js,:html,false] :comment Wether or not to comment the output and in
    #   what style. (default=js)
    def banner(options = {}, &_block)
      options = {
        comment: :js
      }.update(options)

      if block_given?
        @_banner = yield.to_s
      elsif !@_banner
        @_banner = default_banner.join("\n")
      end

      if options[:comment]
        comment(@_banner, style: options[:comment])
      else
        @_banner
      end
    end

    # Actually perform the release
    def run!
      project.mode = :release

      # Validate paths
      validate_paths!

      # Extract mockup
      copy_source_path_to_build_path!

      validate_stack!

      # Run stack
      run_stack!

      # Run finalizers
      run_finalizers!

      # Cleanup
      cleanup! if config[:cleanup_build]
    ensure
      project.mode = nil
    end

    # @param [String] string The string to comment
    #
    # @option options [:html, :css, :js] :style The comment style to use
    #   (default=:js, which is the same as :css)
    # @option options [Boolean] :per_line Comment per line or make one block? (default=true)
    def comment(string, options = {})
      options = {
        style: :css,
        per_line: true
      }.update(options)

      commenters = {
        html: proc { |s| "<!-- #{s} -->" },
        css: proc { |s| "/* #{s} */" },
        js: proc { |s| "/* #{s} */" }
      }

      commenter = commenters[options[:style]] || commenters[:js]

      if options[:per_line]
        string = string.split(/\r?\n/)
        string.map { |s| commenter.call(s) }.join("\n")
      else
        commenter.call(string)
      end
    end

    protected

    def get_files_default_path
      build_path
    end

    def default_banner
      banner = [
        "Version : #{scm.version}",
        "Date  : #{scm.date.strftime('%Y-%m-%d')}"
      ]

      # Find longest line
      size = banner.map(&:size).max

      # Pad all lines
      banner.map! { |b| "= #{b.ljust(size)} =" }

      div = "=" * banner.first.size
      banner.unshift(div)
      banner << div
    end

    # ==============
    # = The runway =
    # ==============

    # Checks if build path exists (and cleans it up)
    # Checks if target path exists (if not, creates it)
    def validate_paths!
      if build_path.exist?
        log self, "Cleaning up previous build \"#{build_path}\""
        rm_rf(build_path)
      end

      unless target_path.exist? # rubocop:disable Style/GuardClause
        log self, "Creating target path \"#{target_path}\""
        mkdir target_path
      end
    end

    # Checks if the project will be runned
    # If config[:blank] is true it will automatically add UrlRelativizer or Mockup processor
    def validate_stack!
      return if config[:blank]

      mockup_options = {}
      relativizer_options = {}

      unless find_in_stack(Roger::Release::Processors::Mockup)
        @stack.unshift([Roger::Release::Processors::Mockup.new, mockup_options])
      end

      # rubocop:disable Style/GuardClause
      unless find_in_stack(Roger::Release::Processors::UrlRelativizer)
        @stack.push([Roger::Release::Processors::UrlRelativizer.new, relativizer_options])
      end
    end

    # Find a processor in the stack
    def find_in_stack(klass)
      @stack.find { |(processor, _options)| processor.class == klass }
    end

    def copy_source_path_to_build_path!
      if config[:cp]
        copy_source_path_to_build_path_using_system
      else
        mkdir(build_path)
        cp_r(source_path.children, build_path)
      end
    end

    def copy_source_path_to_build_path_using_system
      command = [config[:cp]].flatten
      system(Shellwords.join(command + ["#{source_path}/", build_path.to_s]))
    end

    def run_stack!
      @stack = self.class.default_stack.dup if @stack.empty?

      # call all objects in @stack
      @stack.each do |task|
        if task.is_a?(Array)
          task[0].call(self, task[1])
        else
          task.call(self)
        end
      end
    end

    # Will run all finalizers, if no finalizers are set it will take the
    # default finalizers.
    #
    # If config[:blank] is true, it will not use the default finalizers
    def run_finalizers!
      @finalizers = self.class.default_finalizers.dup if @finalizers.empty? && !config[:blank]

      # call all objects in @finalizes
      @finalizers.each do |finalizer|
        finalizer[0].call(self, finalizer[1])
      end
    end

    def cleanup!
      log(self, "Cleaning up build path #{build_path}")
      rm_rf(build_path)
    end
  end
end

require File.dirname(__FILE__) + "/release/scm"
require File.dirname(__FILE__) + "/release/injector"
require File.dirname(__FILE__) + "/release/cleaner"
require File.dirname(__FILE__) + "/release/finalizers"
require File.dirname(__FILE__) + "/release/processors"
