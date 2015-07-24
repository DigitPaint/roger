require File.dirname(__FILE__) + "/helpers/capture"
require File.dirname(__FILE__) + "/helpers/partial"

module Roger
  class Template
    # The context that is passed to all templates
    class TemplateContext
      include Helpers::Capture
      include Helpers::Partial

      def initialize(template, env = {})
        @_template = template
        @_env = env
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
    end
  end
end
