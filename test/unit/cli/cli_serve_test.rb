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


    # roger serve
    def test_has_serve_command
      assert_includes Cli::Base.tasks.keys, "serve"
    end

    # roger server
    def test_serve_default_options
      out, err = run_command(%w{serve})

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end

    def test_serve_with_custom_host
      out, err = run_command(%w{serve --host=localhost})

      assert_includes out, "9000"
      assert_includes out, "localhost"
      assert_includes out, "WEBrick"
    end

    def test_serve_with_custom_port
      out, err = run_command(%w{serve --port=8888})

      assert_includes out, "8888"
      assert_includes out, "0.0.0.0"
      assert_includes out, "WEBrick"
    end

    def test_serve_with_custom_handler
      out, err = run_command(%w{serve --handler=mongrel})

      assert_includes out, "9000"
      assert_includes out, "0.0.0.0"
      assert_includes out, "Mongrel"
    end


  end
end