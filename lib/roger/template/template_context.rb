require File.dirname(__FILE__) + "/helpers/capture"
require File.dirname(__FILE__) + "/helpers/partial"
require File.dirname(__FILE__) + "/helpers/rendering"

module Roger
  class Template
    # The context that is passed to all templates
    class TemplateContext
      include Helpers::Capture
      include Helpers::Partial
      include Helpers::Rendering

      def initialize(renderer, env = {})
        @_renderer = renderer
        @_env = env
      end

      def renderer
        @_renderer
      end

      # The current Roger::Template in use
      def template
        @_renderer.current_template
      end

      # Access to the front-matter of the document (if any)
      def document
        @_data ||= OpenStruct.new(@_renderer.data)
      end

      # The current environment variables.
      def env
        @_env
      end
    end
  end
end
