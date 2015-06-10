require "./lib/roger/cli.rb"
require "test/unit"

require File.dirname(__FILE__) + "/../../helpers/cli"

module Roger
  # Test `roger --version` command
  class CliVersionTest < ::Test::Unit::TestCase
    include TestCli

    def test_minus_minus_verson
      out, _err = run_command(%w(--version))
      assert_includes out, Roger::VERSION
    end

    def test_version_command
      out, _err = run_command(%w(version))
      assert_includes out, Roger::VERSION
    end
  end
end
