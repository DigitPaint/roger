require "test_helper"
require File.dirname(__FILE__) + "../../../../lib/roger/rack/roger"

module Roger
  module Rack
    # Test Roger Rack
    class ServerTest < ::Test::Unit::TestCase
      def setup
        @project = Project.new(File.dirname(__FILE__) + "/../../project", rogerfile_path: false)
        @app = ::Roger::Rack::Roger.new(@project)
      end

      def test_middleware_renders_template
        request = ::Rack::MockRequest.new(@app)
        response = request.get("/formats/erb")

        assert response.body.include?("ERB format")
      end
    end
  end
end
