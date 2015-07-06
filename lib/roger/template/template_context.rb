module Roger
  class Template
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
end
