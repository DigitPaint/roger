require "test_helper"
require "./lib/roger/cli"

require File.dirname(__FILE__) + "/../../helpers/cli"

module Roger
  module Cli
    # Monkeypatching the server command for testing
    class Serve
      # Stop start from being called
      remove_invocation :start

      # Wrap start so we can immediately stop it
      def real_start
        # Let's stop immediately so we can inspect output.
        start do |server|
          case server
          when Puma::Launcher
            # Most unfortunately we have to do it using an exception because
            # Puma will yield before actually starting the server resulting in failures
            fail "Stop"
          else
            server.stop
          end
        end
      rescue # rubocop:disable all
        # Nothing to do.
      end
    end
  end
end

module Roger
  # These tests ar for the roger serve command
  class CliServeTest < ::Test::Unit::TestCase
    include TestCli

    def setup
      @base_path = File.dirname(__FILE__) + "/../../project"
    end

    def teardown
      Cli::Base.project = nil
    end

    # roger serve
    def test_has_serve_command
      assert_includes Cli::Base.tasks.keys, "serve"
    end

    # roger server
    def test_serve_default_options
      out, _err = run_command(%w(serve))

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_host
      out, _err = run_command(%w(serve --host=localhost))

      assert_includes out, "9000"
      assert_includes out, "localhost"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_port
      out, _err = run_command(%w(serve --port=8888))

      assert_includes out, "8888"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_handler
      out, _err = run_command(%w(serve --handler=webrick))

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end
  end

  # These tests ar for the roger serve command with a rogerfile config
  class CliServeWithRogerfileTest < ::Test::Unit::TestCase
    include TestCli

    def test_serve_with_port_in_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve)) do |m|
        m.serve do |s|
          s.port = 9001
        end
      end

      assert_includes out, "9001"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_host_in_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve)) do |m|
        m.serve do |s|
          s.host = "127.0.0.1"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "127.0.0.1"
      assert_includes out, "Puma"
    end

    def test_serve_with_handler_in_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve)) do |m|
        m.serve do |s|
          s.handler = "webrick"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end

    def test_serve_with_custom_port_should_override_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve --port=9002)) do |m|
        m.serve do |s|
          s.port = 9001
        end
      end

      assert_includes out, "9002"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_host_should_override_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve --host=localhost)) do |m|
        m.serve do |s|
          s.host = "127.0.0.1"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "localhost"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_handler_should_override_rogerfile
      out, _err = run_command_with_rogerfile(%w(serve --handler=webrick)) do |m|
        m.serve do |s|
          s.handler = "puma"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end
  end
end
