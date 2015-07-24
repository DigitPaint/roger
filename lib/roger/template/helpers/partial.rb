module Roger
  class Template
    module Helpers
      # The partial helper
      module Partial
        # rubocop:disable Lint/Eval
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
end
