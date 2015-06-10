module Roger
  # The resolver is here to resolve urls to paths and sometimes vice-versa
  class Resolver
    attr_reader :load_paths

    def initialize(paths)
      fail ArgumentError, "Resolver base path can't be nil" if paths.nil?

      # Convert to paths
      @load_paths = [paths].flatten.map { |p| Pathname.new(p) }
    end

    # @param [String] url The url to resolve to a path
    # @param [Hash] options Options
    #
    # @option options [true,false] :exact_match Wether or not to match exact paths,
    #   this is mainly used in the path_to_url method to match .js, .css, etc files.
    # @option options [String] :preferred_extension The part to chop off
    #   and re-add to search for more complex double-extensions. (Makes it possible to have context
    #   aware partials)
    def find_template(url, options = {})
      options = {
        exact_match: false,
        preferred_extension: "html"
      }.update(options)

      orig_path, _qs, _anch = strip_query_string_and_anchor(url.to_s)

      output = nil

      load_paths.find do |load_path|
        path = File.join(load_path, orig_path)

        # If it's an exact match we're done
        if options[:exact_match] && File.exist?(path)
          output = Pathname.new(path)
        else
          output = find_file_with_extension(path, options[:preferred_extension])
        end
      end

      output
    end
    alias_method :url_to_path, :find_template

    # Convert a disk path on file to an url
    def path_to_url(path, relative_to = nil)
      # Find the parent path we're in
      path = Pathname.new(path).realpath
      base = load_paths.find { |lp| path.to_s =~ /\A#{Regexp.escape(lp.realpath.to_s)}/ }

      path = path.relative_path_from(base).cleanpath

      if relative_to
        relative_path_to_url(path, relative_to, base).to_s
      else
        "/#{path}"
      end
    end

    def url_to_relative_url(url, relative_to_path)
      # Skip if the url doesn't start with a / (but not with //)
      return false unless url =~ %r{\A/[^/]}

      path, qs, anch = strip_query_string_and_anchor(url)

      # Get disk path
      if true_path =  url_to_path(path, exact_match: true)
        path = path_to_url(true_path, relative_to_path)
        path += qs if qs
        path += anch if anch
        path
      else
        false
      end
    end

    def strip_query_string_and_anchor(url)
      url = url.dup

      # Strip off anchors
      anchor = nil
      url.gsub!(/(#.+)\Z/) do |r|
        anchor = r
        ""
      end

      # Strip off query strings
      query = nil
      url.gsub!(/(\?.+)\Z/) do |r|
        query = r
        ""
      end

      [url, query, anchor]
    end

    protected

    # Tries all extensions on path to see what file exists
    # @return [Pathname,nil] returns a pathname of the full file path if found. nil otherwise
    def find_file_with_extension(path, preferred_extension)
      output = nil

      file_path = path

      # If it's a directory, add "/index"
      file_path = File.join(file_path, "index") if File.directory?(file_path)

      # Strip of extension
      if path =~ /\.#{preferred_extension}\Z/
        file_path.sub!(/\.#{preferred_extension}\Z/, "")
      end

      possible_extensions(preferred_extension).find do |ext|
        path_with_extension = file_path + "." + ext
        if File.exist?(path_with_extension)
          output = Pathname.new(path_with_extension)
        end
      end
      output
    end

    # Makes a list of all Tilt extensions
    # Also adds a list of double extensions. Example:
    # tilt_extensions = %w(erb md); second_extension = "html"
    # return %w(erb md html.erb html.md)
    def possible_extensions(second_extension)
      extensions = Tilt.default_mapping.template_map.keys + Tilt.default_mapping.lazy_map.keys
      extensions + extensions.map { |ext| "#{second_extension}.#{ext}" }
    end

    def relative_path_to_url(path, relative_to, base)
      relative_to = Pathname.new(File.dirname(relative_to.to_s))

      # If relative_to is an absolute path
      if relative_to.to_s =~ %r{\A/}
        relative_to = relative_to.relative_path_from(base).cleanpath
      end

      Pathname.new("/" + path.to_s).relative_path_from(Pathname.new("/" + relative_to.to_s))
    end
  end
end
