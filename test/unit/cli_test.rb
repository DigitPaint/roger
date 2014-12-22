require "./lib/roger/cli.rb"
require "test/unit"

module Roger
  class CliTest < ::Test::Unit::TestCase

    def test_register_generators
      assert_includes Cli::Base.subcommands, "generate"
    end

  end
end