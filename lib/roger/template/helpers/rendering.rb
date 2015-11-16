module Roger
  class Template
    module Helpers
      # The partial helper
      module Rendering
        # Render any file on disk
        #
        # @see Renderer#render_file
        def render_file(path, options = {})
          renderer.render_file(path, options)
        end
      end
    end
  end
end
