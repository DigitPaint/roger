require "./lib/roger/cli.rb"
require "test/unit"

require File.dirname(__FILE__) + "/../../helpers/cli"

# These tests ar for the roger serve command

class Roger::Cli::Serve
  def start
    # Let's not start it.
  end
end


module Roger
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
      out, err = run_command(%w{serve})

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_host
      out, err = run_command(%w{serve --host=localhost})

      assert_includes out, "9000"
      assert_includes out, "localhost"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_port
      out, err = run_command(%w{serve --port=8888})

      assert_includes out, "8888"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_handler
      out, err = run_command(%w{serve --handler=webrick})

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end

  end

  class CliServeWithMockupfileTest < ::Test::Unit::TestCase
    include TestCli

    def test_serve_with_port_in_mockupfile
      out, err = run_command_with_mockupfile(%w{serve}) do |m|
        m.serve do |s|
          s.port = 9001
        end
      end

      assert_includes out, "9001"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_host_in_mockupfile
      out, err = run_command_with_mockupfile(%w{serve}) do |m|
        m.serve do |s|
          s.host = "127.0.0.1"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "127.0.0.1"
      assert_includes out, "Puma"
    end

    def test_serve_with_handler_in_mockupfile
      out, err = run_command_with_mockupfile(%w{serve}) do |m|
        m.serve do |s|
          s.handler = "webrick"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end

    def test_serve_with_custom_port_should_override_mockupfile
      out, err = run_command_with_mockupfile(%w{serve --port=9002}) do |m|
        m.serve do |s|
          s.port = 9001
        end
      end

      assert_includes out, "9002"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_host_should_override_mockupfile
      out, err = run_command_with_mockupfile(%w{serve --host=localhost}) do |m|
        m.serve do |s|
          s.host = "127.0.0.1"
        end
      end

      assert_includes out, "9000"
      assert_includes out, "localhost"
      assert_includes out, "Puma"
    end

    def test_serve_with_custom_handler_should_override_mockupfile
      out, err = run_command_with_mockupfile(%w{serve --handler=webrick}) do |m|
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