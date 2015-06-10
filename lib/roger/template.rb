require "tilt"
require "mime/types"
require "yaml"
require "ostruct"

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

  # The context that is passed to all templates
  class TemplateContext
    attr_accessor :_content_for_blocks

    def initialize(template, env = {})
      @_content_for_blocks = {}
      @_template = template
      @_env = env

      # Block counter to make sure erbtemp binding is always unique
      @block_counter = 0
    end

    # The current Roger::Template in use
    def template
      @_template
    end

    # Access to the front-matter of the document (if any)
    def document
      @_data ||= OpenStruct.new(template.data)
    end

    # The current environment variables.
    def env
      @_env
    end

    # Capture content in blocks in the template for later use in the layout.
    # Currently only works in ERB templates. Use like this in the template:
    #
    # ```
    #   <% content_for :name %> bla bla <% end %>
    # ```
    #
    # Place it like this in the layout:
    #
    # ```
    #   <%= yield :name %>
    # ```
    def content_for(block_name, &block)
      @_content_for_blocks[block_name] = capture(&block)
    end

    # rubocop:disable Lint/Eval
    def capture(&block)
      unless template.template.is_a?(Tilt::ERBTemplate)
        fail ArgumentError, "content_for works only with ERB Templates"
      end

      @block_counter += 1
      counter = @block_counter

      eval "@_erbout_tmp#{counter} = _erbout", block.binding
      eval "_erbout = \"\"", block.binding
      t = Tilt::ERBTemplate.new { "<%= yield %>" }
      t.render(&block)
    ensure
      eval "_erbout = @_erbout_tmp#{counter}", block.binding
    end

    def partial(name, options = {}, &block)
      template_path = template.find_template(name, :partials_path)
      if template_path
        out = render_partial(template_path, options, &block)
        if block_given?
          eval "_erbout.concat(#{out.dump})", block.binding
        else
          out
        end
      else
        fail ArgumentError, "No such partial #{name}, referenced from #{template.source_path}"
      end
    end
    # rubocop:enable Lint/Eval

    protected

    # Capture a block and render the partial
    def render_partial(template_path, options, &block)
      partial_template = Tilt.new(template_path.to_s)
      if block_given?
        block_content = capture(&block)
      else
        block_content = ""
      end
      partial_template.render(self, options[:locals] || {}) { block_content }
    end
  end
end
