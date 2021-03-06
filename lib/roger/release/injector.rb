require "tilt"
module Roger
  # The Injector can inject variables and files into other files based on regexps.
  #
  # Inject VERSION / DATE (i.e. in TOC)
  # r.inject({"VERSION" => release.version, "DATE" => release.date}, :into => %w{_doc/toc.html})
  #
  # Inject CHANGELOG
  # r.inject({"CHANGELOG" => {file: "", filter: BlueCloth}}, :into => %w{_doc/changelog.html})
  class Release::Injector
    # @example Simple variable injection (replaces [VARIABLE] into all .css files)
    #     {"[VARIABLE]" => "replacement"}, :into => %w{**/*.css}
    #
    # @example Regex variable injection (replaces all matches into test.js files)
    #     {/\/\*\s*\[BANNER\]\s*\*\// => "replacement"}, :into => %w{javacripts/test.js}
    #
    # @example Simple variable injection with filtering (replaces [VARIABLE] with :content
    #   run through the markdown processor into all .html files)
    #
    #     {"[VARIABLE]" => {content: "# header one", processor: "md"}, :into => %w{**/*.html}
    #
    # @example Full file injection (replaces all matches of [CHANGELOG] with the contents
    #   of "CHANGELOG.md" into _doc/changelog.html)
    #
    #     {"CHANGELOG" => {file: "CHANGELOG.md"}}, :into => %w{_doc/changelog.html}
    #
    # @example Full file injection with filtering (replaces all matches of [CHANGELOG]
    #   with the contents of "CHANGELOG" which ran through Markdown compresser
    #   into _doc/changelog.html)
    #
    #     {"CHANGELOG" => {file: "CHANGELOG", processor: "md"}}, :into => %w{_doc/changelog.html}
    #
    # Processors are based on Tilt (https://github.com/rtomayko/tilt).
    # Currently supported/tested processors are:
    #
    # * 'md' for Markdown (bluecloth)
    #
    # Injection files are relative to the :source_path
    #
    # @param [Hash] variables Variables to inject. See example for more info
    # @option options [Array] :into An array of file globs relative to the build_path
    def initialize(variables, options)
      @variables = variables
      @options = options
    end

    def call(release, options = {})
      @options.update(options)
      files = release.get_files(@options[:into])

      files.each do |f|
        c = File.read(f)
        injected_vars = []
        @variables.each do |variable, injection|
          if c.gsub!(variable, get_content(injection, release))
            injected_vars << variable
          end
        end
        unless injected_vars.empty?
          release.log(self, "Injected variables #{injected_vars.inspect} into #{f}")
        end
        File.open(f, "w") { |fh| fh.write c }
      end
    end

    def get_content(injection, release)
      case injection
      when String
        injection
      when Hash
        get_complex_injection(injection, release)
      else
        injection.to_s
      end
    end

    def get_complex_injection(injection, release)
      content = injection_content(injection, release)

      raise ArgumentError, "No :content or :file specified" unless content

      if injection[:processor]
        tmpl = Tilt[injection[:processor]]
        raise(ArgumentError, "Unknown processor #{injection[:processor]}") unless tmpl

        (tmpl.new { content }).render
      else
        content
      end
    end

    def injection_content(injection, release)
      if injection[:file]
        File.read(release.source_path + injection[:file])
      else
        injection[:content]
      end
    end
  end
end
