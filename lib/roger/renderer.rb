require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/template/template_context"
require File.dirname(__FILE__) + "/resolver"

module Roger
  # Roger Renderer class
  #
  # The renderer will set up an environment so you can consistently render templates
  # within that environment
  class Renderer
    MAX_ALLOWED_TEMPLATE_NESTING = 10

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

    attr_accessor :data
    attr_reader :template_nesting

    def initialize(env = {}, options = {})
      @options = options
      @context = prepare_context(env)

      @paths = {
        partials: [@options[:partials_path]].flatten,
        layouts: [@options[:layouts_path]].flatten
      }

      # State data. Whenever we render a new template
      # we need to update:
      #
      # - data from front matter
      # - template_nesting
      # - current_template
      @data = {}
      @template_nesting = []
    end

    # The render function
    #
    # The render function will take care of rendering the right thing
    # in the right context. It will:
    #
    # - Wrap templates with layouts if it's defined in the frontmatter and
    #   load them from the right layout path.
    # - Render only partials if called from within an existing template
    #
    # If you just want to render an arbitrary file, use #render_file instead
    #
    # @option options [Hash] :locals Locals to use during rendering
    # @option options [String] :source The source for the template
    # @option options [String, nil] :layout The default layout to use
    def render(path, options = {}, &block)
      template, layout = template_and_layout_for_render(path, options)

      # Set new current template
      template_nesting.push(template)

      # Copy data to our data store. A bit clunky; as this should be inherited
      @data = {}.update(@data).update(template.data)

      # Render the template first so we have access to
      # it's data in the layout.
      render_result = template.render(options[:locals] || {}, &block)

      # Wrap it in a layout
      layout.render do
        render_result
      end
    ensure
      # Only pop the template from the nesting if we actually
      # put it on the nesting stack.
      template_nesting.pop if template
    end

    # Render any file on disk. No magic. Just rendering.
    #
    # A couple of things to keep in mind:
    # - The file will be rendered in this rendering context
    # - Does not have layouts or block style
    # - When you pass a relative path and we are within another template
    #   it will be relative to that template.
    #
    # @options options [Hash] :locals
    def render_file(path, options = {})
      pn = absolute_path_from_current_template(path)

      template = template(pn.to_s, nil)

      # Track rendered file also on the rendered stack
      template_nesting.push(template)

      template.render(options[:locals] || {})
    ensure
      # Only pop the template from the nesting if we actually
      # put it on the nesting stack.
      template_nesting.pop if template
    end

    # The current template being rendered
    def current_template
      template_nesting.last
    end

    # The parent template in the nesting.
    def parent_template
      template_nesting[-2]
    end

    protected

    def absolute_path_from_current_template(path)
      pn = Pathname.new(path)

      if pn.relative?
        # We're explicitly checking for source_path instead of real_source_path
        # as you could also just have an inline template.
        if current_template && current_template.source_path
          (Pathname.new(current_template.source_path).dirname + pn).realpath
        else
          err = "Only within another template you can use relative paths"
          fail ArgumentError, err
        end
      else
        pn.realpath
      end
    end

    def template_and_layout_for_render(path, options = {})
      # A previous template has been set so it's a partial
      # If no previous template is set, we're
      # at the top level and this means we get to do layouts!
      template_type = current_template ? :partial : :template
      template = template(path, options[:source], template_type)

      layout = layout_for_template(template, options)

      [template, layout]
    end

    # Gets the layout for a specific template
    def layout_for_template(template, options)
      layout_name = template.data.key?(:layout) ? template.data[:layout] : options[:layout]

      # Only attempt to load layout when:
      # - Template is the toplevel template
      # - A layout_name is available
      return BlankTemplate.new if current_template || !layout_name

      template(layout_name, nil, :layout)
    end

    # Will check the template nesting if we haven't already
    # rendered this path before. If it has we'll throw an argumenteerror
    def prevent_recursion!(template)
      # If this template is not a real file it cannot ever conflict.
      return unless template.real_source_path

      caller_templates = template_nesting.select do |t|
        t.real_source_path == template.real_source_path
      end

      # We're good, no deeper recursion then MAX_ALLOWED_TEMPLATE_NESTING
      return if caller_templates.length <= MAX_ALLOWED_TEMPLATE_NESTING

      err = "Recursive render detected for '#{template.source_path}'"
      err += " in '#{current_template.source_path}'"

      fail ArgumentError, err
    end

    # Will instantiate a Template or throw an ArgumentError
    # if it could not find the template
    def template(path, source, type = :template)
      if source
        template = Template.new(source, @context, source_path: path)
      else
        case type
        when :partial
          template_path = find_partial(path)
        when :layout
          template_path = find_layout(path)
        else
          template_path = path
        end

        if template_path && File.exist?(template_path)
          template = Template.open(template_path, @context)
        else
          template_not_found!(type, path)
        end
      end

      prevent_recursion!(template)

      template
    end

    def template_not_found!(type, path)
      err = "No such #{type} #{path}"
      err += " in #{@current_template.source_path}" if @current_template
      fail ArgumentError, err
    end

    # Find a partial
    def find_partial(name)
      current_path, current_ext = current_template_path_and_extension

      # Try to find _ named partials first.
      # This will alaso search for partials relative to the current path
      local_name = [File.dirname(name), "_" + File.basename(name)].join("/")
      resolver = Resolver.new([File.dirname(current_path)] + @paths[:partials])
      result = resolver.find_template(local_name, prefer: current_ext)

      return result if result

      # Try to look for templates the old way
      resolver = Resolver.new(@paths[:partials])
      resolver.find_template(name, prefer: current_ext)
    end

    def find_layout(name)
      _, current_ext = current_template_path_and_extension

      resolver = Resolver.new(@paths[:layouts])
      resolver.find_template(name, prefer: current_ext)
    end

    def current_template_path_and_extension
      path = nil
      extension = nil

      # We want the preferred extension to be the same as ours
      if current_template
        path = current_template.source_path
        extension = self.class.target_extension_for(path)
      end

      [path, extension]
    end

    # Will set up a new  template context for this renderer
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
