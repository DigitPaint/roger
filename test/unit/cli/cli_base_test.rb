require "./lib/roger/cli.rb"
require "test/unit"

module Roger
  class CliBaseTest < ::Test::Unit::TestCase

    def test_has_test_command
      assert_includes Cli::Base.tasks.keys, "test"
    end

    def test_has_serve_command
      assert_includes Cli::Base.tasks.keys, "serve"
    end

    def test_has_release_command
      assert_includes Cli::Base.tasks.keys, "release"
    end

    def test_has_generate_command
      assert_includes Cli::Base.tasks.keys, "generate"
    end

    def test_has_version_command
      assert_includes Cli::Base.tasks.keys, "version"
    end

  end
end