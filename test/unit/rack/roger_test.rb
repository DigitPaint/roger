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
        assert_equal "Roger", response.headers["X-Handled-By"]
      end

      def test_middleware_does_not_render_unrenderables
        @project.construct.file "html/myjpeg.jpg", "JPG"
        request = ::Rack::MockRequest.new(@app)
        response = request.get("/myjpeg.jpg")

        assert response.body.include?("JPG")
        assert_equal nil, response.headers["X-Handled-By"]
      end

      def test_middleware_does_not_render_unwanteds
        @project.construct.file "html/mysass.scss", ".scss{}"
        request = ::Rack::MockRequest.new(@app)
        response = request.get("/mysass.scss")

        assert response.body.include?(".scss{}")
        assert_equal nil, response.headers["X-Handled-By"]
      end

      def test_renderer_options_are_passed
        @project.options[:renderer][:layout] = {
          "html.erb" => "bracket"
        }

        @project.construct.file "layouts/bracket.html.erb", "[<%= yield %>]"
        @project.construct.file "html/test.html.erb", "<%= 'test' %>"

        request = ::Rack::MockRequest.new(@app)
        response = request.get("/test")

        assert_equal "[test]", response.body
      end
    end
  end
end
