require "test_helper"

module Roger
  module Rack
    # Test Roger Rack
    class ServerTest < ::Test::Unit::TestCase
      def setup
        @project = Testing::MockProject.new
        @app = ::Roger::Rack::Roger.new(@project)
      end

      def teardown
        @project.destroy
      end

      def test_middleware_renders_template
        @project.construct.file "html/erb.html.erb", "ERB format"
        request = ::Rack::MockRequest.new(@app)
        response = request.get("/erb")

        assert response.body.include?("ERB format")
      end
    end
  end
end
