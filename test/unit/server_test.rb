require "test_helper"
require File.dirname(__FILE__) + "../../../lib/roger/rack/roger"

module Roger
  # Test Roger Server test
  class ServerTest < ::Test::Unit::TestCase
    def setup
      @project = Project.new(File.dirname(__FILE__) + "/../../project", rogerfile_path: false)
      @server = Server.new(@project)
      @host = "127.0.0.1"
    end

    def test_port_free
      port = 5192

      # Port is free
      assert @server.send(:port_free?, @host, port)

      s = TCPServer.new(@host, port)

      # Port is not free
      assert !@server.send(:port_free?, @host, port)
    ensure
      s.close
    end

    def test_free_port_for_host_above
      port = 9000

      # Make sure something is running on port
      begin
        s = TCPServer.new(@host, port)
      rescue SocketError, Errno::EADDRINUSE # rubocop:disable all
        # Something already must be running on port
      end

      next_port = @server.send(:free_port_for_host_above, @host, port)
      assert next_port > port

    ensure
      s.close
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
