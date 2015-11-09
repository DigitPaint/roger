module Roger
  # The resolver is here to resolve urls to paths and sometimes vice-versa
  class Resolver
    # Maps output extensions to template extensions to find
    # source files.
    EXTENSION_MAP = {
      "html" => %w(
        rhtml
        markdown
        mkd
        md
        ad
        adoc
        asciidoc
        rdoc
        textile
      ),
      "csv" => %w(
        rcsv
      ),
      # These are generic template languages
      nil => %w(
        erb
        erubis
        str
      )
    }

    attr_reader :load_paths

    def initialize(paths)
      fail ArgumentError, "Resolver base path can't be nil" if paths.nil?

      # Convert to paths
      @load_paths = [paths].flatten.map { |p| Pathname.new(p) }
    end

    # @param [String] url The url to resolve to a path
    # @param [Hash] options Options
    #
    # @option options [String] :prefer The preferred template extension. When searching for
    #  templates, the preferred template extension defines what file type we're requesting
    #  when we ask for a file without an extension
    def find_template(url, options = {})
      options = {
        prefer: "html"
      }.update(options)

      orig_path, _qs, _anch = strip_query_string_and_anchor(url.to_s)

      output = nil

      load_paths.find do |load_path|
        path = File.join(load_path, orig_path)
        output = find_template_path(path, options)
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

    # Finds the template path for "name"
    def find_template_path(name, options = {})
      options = {
        prefer: "html", # Prefer a template with extension
      }.update(options)

      path = sanitize_name(name, options[:prefer])

      # Exact match
      return Pathname.new(path) if File.exist?(path)

      # Split extension and path
      path_extension, path_without_extension = split_path(path)

      # Get possible output extensions for path_extension
      template_extensions = template_extensions_for_output(path_extension, options[:prefer])

      # Let's look at the disk to see what files we've got
      files = Dir.glob(path_without_extension + ".*")

      results = filter_files(files, path, path_without_extension, template_extensions)

      # Our result if any
      results[0] && Pathname.new(results[0])
    end

    # Filter a list of files to see wether or not we can process them.
    # Will take into account that the longest match with path will
    # be the first result.
    def filter_files(files, path, path_without_extension, template_extensions)
      results = []

      files.each do |file|
        if file.start_with?(path)
          match = path
        else
          match = path_without_extension
        end

        processable_extensions = file[(match.length + 1)..-1].split(".")

        # All processable_extensions must be processable
        # by a template_extension
        next unless (processable_extensions - template_extensions).length == 0

        if file.start_with?(path)
          # The whole path is found in the filename, not just
          # the path without the extension.
          # it must have priority over all else
          results.unshift(file)
        else
          results.push(file)
        end
      end
      results
    end

    # Check if the name is a directory and append index
    # Append preferred extension or html if it doesn't have one yet
    def sanitize_name(name, prefer = nil)
      path = name.to_s

      # If it's a directory append "index"
      path = File.join(path, "index") if File.directory?(name)

      # Check if we haven't got an extension
      # we'll assume you're looking for prefer or "html" otherwise
      path += ".#{prefer || 'html'}" unless File.basename(path).include?(".")

      path
    end

    # Split path in to extension an path without extension
    def split_path(path)
      path = path.to_s
      extension = File.extname(path)[1..-1]
      path_without_extension = path.sub(/\.#{Regexp.escape(extension)}\Z/, "")
      [extension, path_without_extension]
    end

    def template_extensions_for_output(ext, prefer = nil)
      template_extensions = []

      # The preferred template_extension is first
      template_extensions += prefer.to_s.split(".") if prefer

      # Any exact template matches for extension
      template_extensions += EXTENSION_MAP[ext] if EXTENSION_MAP[ext]

      # Any generic templates
      template_extensions += EXTENSION_MAP[nil]

      # Myself to pass extension matching later on
      template_extensions += [ext]

      template_extensions
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
