require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/template/template_context"
require File.dirname(__FILE__) + "/resolver"

module Roger
  # Roger Renderer class
  #
  # The renderer will set up an environment so you can consistently render templates
  # within that environment
  class Renderer
    class << self
      # Register a helper module that should be included in
      # every template context.
      def helper(mod)
        @helpers ||= []
        @helpers << mod
      end

      def helpers
        @helpers || []
      end

      # Try to infer the final extension of the output file.
      def target_extension_for(path)
        if type = MIME::Types[target_mime_type_for(path)].first
          # Dirty little hack to enforce the use of .html instead of .htm
          if type.sub_type == "html"
            "html"
          else
            type.extensions.first
          end
        else
          File.extname(path.to_s).sub(/^\./, "")
        end
      end

      def source_extension_for(path)
        parts = File.basename(File.basename(path.to_s)).split(".")
        if parts.size > 2
          parts[-2..-1].join(".")
        else
          File.extname(path.to_s).sub(/^\./, "")
        end
      end

      # Try to figure out the mime type based on the Tilt class and if that doesn't
      # work we try to infer the type by looking at extensions (needed for .erb)
      def target_mime_type_for(path)
        mime =
          mime_type_from_template(path) ||
          mime_type_from_filename(path) ||
          mime_type_from_sub_extension(path)

        mime.to_s if mime
      end

      protected

      # Check last template processor default
      # output mime type
      def mime_type_from_template(path)
        templates = Tilt.templates_for(path.to_s)
        templates.last && templates.last.default_mime_type
      end

      def mime_type_from_filename(path)
        MIME::Types.type_for(File.basename(path.to_s)).first
      end

      # Will get mime_type from source_path extension
      # but it will only look at the second extension so
      # .html.erb will look at .html
      def mime_type_from_sub_extension(path)
        parts = File.basename(path.to_s).split(".")
        MIME::Types.type_for(parts[0..-2].join(".")).first if parts.size > 2
      end
    end

    attr_accessor :data, :current_template

    def initialize(env = {}, options = {})
      @options = options
      @context = prepare_context(env)

      # State data. Whenever we render a new template
      # we need to update:
      #
      # - data from front matter
      # - current_template
      @data = {}
      @current_template = nil
    end

    def render(path, options = {}, &block)
      prev_template = @current_template
      @current_template = template(path, &block)

      @data = {}.update(@data).update(@current_template.data)

      locals = options[:locals] || {}

      layout_path = find_template(
        @current_template.data[:layout],
        :layouts_path, self.class.target_extension_for(path)
      )

      render_result = @current_template.render(locals)

      if layout_path
        layout_template = Template.open(layout_path, @context)
        layout_template.render do
          render_result
        end
      else
        render_result
      end
    ensure
      @current_template = prev_template
    end

    def template(path, &_block)
      if block_given?
        source = yield
        Template.new(source, @context, source_path: path)
      else
        Template.open(path, @context)
      end
    end

    def find_template(name, path_type, extension = nil)
      unless [:partials_path, :layouts_path].include?(path_type)
        fail(ArgumentError, "path_type must be one of :partials_path or :layouts_path")
      end

      return nil unless @options[path_type]

      @resolvers ||= {}
      @resolvers[path_type] ||= Resolver.new(@options[path_type])

      @resolvers[path_type].find_template(name, preferred_extension: extension)
    end

    protected

    # Will set up a new  template context
    def prepare_context(env)
      context = Roger::Template::TemplateContext.new(self, env)

      # Extend context with all helpers
      self.class.helpers.each do |mod|
        context.extend(mod)
      end

      context
    end
  end
end
