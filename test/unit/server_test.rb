require "test_helper"
require File.dirname(__FILE__) + "../../../lib/roger/rack/roger"

module Roger
  # Test Roger Server test
  class ServerTest < ::Test::Unit::TestCase
    def setup
      @project = Project.new(File.dirname(__FILE__) + "/../../project", mockupfile_path: false)
      @server = Server.new(@project)
    end

    # Test to see if env["roger.project"] is set
    def test_env_roger_project_is_set
      test = Class.new do
        def initialize(_app)
        end

        def call(env)
          [200, {}, [env["roger.project"].object_id.to_s]]
        end
      end

      @server.use test

      request = ::Rack::MockRequest.new(@server.send(:application))

      # This is a bit of a clunky comparison but it suffices for now
      assert_equal @project.object_id.to_s, request.get("/").body
    end
  end
end
