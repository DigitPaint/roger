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

      def test_renderer_options_are_passed
        @project.options[:renderer][:layout] = "bracket"

        @project.construct.file "layouts/bracket.html.erb", "[<%= yield %>]"
        @project.construct.file "html/test.html.erb", "<%= 'test' %>"

        request = ::Rack::MockRequest.new(@app)
        response = request.get("/test")

        assert_equal "[test]", response.body
      end
    end
  end
end
