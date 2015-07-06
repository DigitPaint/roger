require "tilt"
require "mime/types"
require "yaml"
require "ostruct"

require File.dirname(__FILE__) + "/template/template_context"

# We're enforcing Encoding to UTF-8
Encoding.default_external = "UTF-8"

module Roger
  # Roger template processing class
  class Template
    # The source
    attr_accessor :source

    # Store the frontmatter
    attr_accessor :data

    # The actual Tilt template
    attr_accessor :template

    # The path to the source file for this template
    attr_accessor :source_path

    class << self
      def open(path, options = {})
        fail "Unknown file #{path}" unless File.exist?(path)
        new(File.read(path), options.update(source_path: path))
      end
    end

    # @option options [String,Pathname] :source_path The path to
    #   the source of the template being processed
    # @option options [String,Pathname] :layouts_path The path to where all layouts reside
    # @option options [String,Pathname] :partials_path The path to where all partials reside
    def initialize(source, options = {})
      @options = options

      self.source_path = options[:source_path]
      self.data, self.source = extract_front_matter(source)
      self.template = Tilt.new(source_path.to_s) { self.source }

      initialize_layout
    end

    def render(env = {})
      context = TemplateContext.new(self, env)

      if @layout_template
        content_for_layout = template.render(context, {}) # yields

        @layout_template.render(context, {}) do |content_for|
          if content_for
            context._content_for_blocks[content_for]
          else
            content_for_layout
          end
        end
      else
        template.render(context, {})
      end
    end

    def find_template(name, path_type)
      unless [:partials_path, :layouts_path].include?(path_type)
        fail(ArgumentError, "path_type must be one of :partials_path or :layouts_path")
      end

      return nil unless @options[path_type]

      @resolvers ||= {}
      @resolvers[path_type] ||= Resolver.new(@options[path_type])

      @resolvers[path_type].find_template(name, preferred_extension: target_extension)
    end

    # Try to infer the final extension of the output file.
    def target_extension
      return @target_extension if @target_extension

      if type = MIME::Types[target_mime_type].first
        # Dirty little hack to enforce the use of .html instead of .htm
        if type.sub_type == "html"
          @target_extension = "html"
        else
          @target_extension = type.extensions.first
        end
      else
        @target_extension = File.extname(source_path.to_s).sub(/^\./, "")
      end
    end

    def source_extension
      parts = File.basename(File.basename(source_path.to_s)).split(".")
      if parts.size > 2
        parts[-2..-1].join(".")
      else
        File.extname(source_path.to_s).sub(/^\./, "")
      end
    end

    # Try to figure out the mime type based on the Tilt class and if that doesn't
    # work we try to infer the type by looking at extensions (needed for .erb)
    def target_mime_type
      mime =
        mime_type_from_template ||
        mime_type_from_filename ||
        mime_type_from_sub_extension

      mime.to_s if mime
    end

    protected

    def initialize_layout
      return unless data[:layout]
      layout_template_path = find_template(data[:layout], :layouts_path)

      @layout_template = Tilt.new(layout_template_path.to_s) if layout_template_path
    end

    def mime_type_from_template
      template.class.default_mime_type
    end

    def mime_type_from_filename
      path = File.basename(source_path.to_s)
      MIME::Types.type_for(path).first
    end

    # Will get mime_type from source_path extension
    # but it will only look at the second extension so
    # .html.erb will look at .html
    def mime_type_from_sub_extension
      parts = File.basename(source_path.to_s).split(".")
      MIME::Types.type_for(parts[0..-2].join(".")).first if parts.size > 2
    end

    # Get the front matter portion of the file and extract it.
    def extract_front_matter(source)
      fm_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

      if match = source.match(fm_regex)
        source = source.sub(fm_regex, "")

        begin
          data = (YAML.load(match[1]) || {}).inject({}) do |memo, (k, v)|
            memo[k.to_sym] = v
            memo
          end
        rescue *YAML_ERRORS => e
          puts "YAML Exception: #{e.message}"
          return false
        end
      else
        return [{}, source]
      end

      [data, source]
    rescue
      [{}, source]
    end
  end
end
