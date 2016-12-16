require "tilt"
require "mime/types"
require "yaml"
require "ostruct"

# We're enforcing Encoding to UTF-8
Encoding.default_external = "UTF-8"

module Roger
  # Blank template is an empty template
  #
  # This is usefull for wrapping other templates
  class BlankTemplate
    def render(_locals = {}, &_block)
      yield if block_given?
    end
  end

  # Roger template processing class
  class Template < BlankTemplate
    # The source
    attr_accessor :source

    # Store the frontmatter
    attr_accessor :data

    # The path to the source file for this template
    attr_accessor :source_path

    # The current tilt template being used
    attr_reader :current_tilt_template

    class << self
      def open(path, context = nil, options = {})
        new(File.read(path), context, options.update(source_path: path))
      end
    end

    # @option options [String,Pathname] :source_path The path to
    #   the source of the template being processed
    def initialize(source, context = nil, options = {})
      @context = context

      self.source_path = options[:source_path]
      self.data, self.source = extract_front_matter(source)

      @templates = Tilt.templates_for(source_path)
    end

    def render(locals = {}, &block)
      @templates.inject(source) do |src, template|
        render_with_tilt_template(template, src, locals, &block)
      end
    end

    # Actual path on disk, nil if it doesn't exist
    # The nil case is mostly used with inline rendering.
    def real_source_path
      return @_real_source_path if @_real_source_path_cached

      @_real_source_path_cached = true
      @_real_source_path = if File.exist?(source_path)
                             Pathname.new(source_path).realpath
                           end
    end

    protected

    # Render source with a specific tilt template class
    def render_with_tilt_template(template_class, src, locals, &_block)
      @current_tilt_template = template_class
      template = template_class.new(source_path) { src }

      block_content = if block_given?
                        yield
                      else
                        ""
                      end

      template.render(@context, locals) do |name|
        if name
          @context._content_for_blocks[name]
        else
          block_content
        end
      end
    end

    # Get the front matter portion of the file and extract it.
    def extract_front_matter(source)
      fm_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

      return [{}, source] unless match = source.match(fm_regex)

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

      [data, source]
    rescue
      [{}, source]
    end
  end
end
