module Roger
  class Template
    module Helpers
      # The partial helper
      module Partial
        def partial(name, locals = {}, &block)
          if locals[:locals]
            options = locals
          else
            options = { locals: locals }
          end
          if block_given?
            partial_with_block(name, options, &block)
          else
            renderer.render(name, options)
          end
        end

        protected

        # rubocop:disable Lint/Eval
        def partial_with_block(name, options, &block)
          block_content = capture(&block)
          result = renderer.render(name, options) { block_content }
          eval "_erbout.concat(#{result.dump})", block.binding
        end
        # rubocop:enable Lint/Eval
      end
    end
  end
end
