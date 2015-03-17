require "./lib/roger/cli.rb"
require "test/unit"

require File.dirname(__FILE__) + "/../../helpers/cli"

# These tests ar for the roger generate command

module CustomGens
  module Generators

    class MockedGenerator < Roger::Generators::Base

      desc "@mocked description"
      argument :path, :type => :string, :required => false, :desc => "Path to generate mockup into"
      argument :another_arg, :type => :string, :required => false, :desc => "Mocked or what?!"

      def test
        # Somewhat ugly way of checking
        raise NotImplementedError
      end
    end

    Roger::Generators.register :mocked, MockedGenerator
  end
end

module Roger
  class CliGenerateTest < ::Test::Unit::TestCase
    include TestCli

    def setup
      @base_path = File.dirname(__FILE__) + "/../../project"
    end

    # roger generate
    def test_has_generate_command
      assert_includes Cli::Base.tasks.keys, "generate"
    end

    def test_help_shows_available_generators
      out, err = run_command %w{help generate}

      assert_includes out, "generate new"
      assert_includes out, "generate mock"
    end

  end
end