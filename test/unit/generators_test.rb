# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/generators.rb"
require "test_construct"

require File.dirname(__FILE__) + "/../helpers/generators"
require File.dirname(__FILE__) + "/../helpers/cli"

module Roger
  # Test Roger Generators
  class GeneratorTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers
    include TestCli

    def setup
      @cli = Cli::Base.new

      # Dirty hack to clean up tasks
      Cli::Generate.tasks.delete("mocked")
      Cli::Generate.tasks.delete("mockery")
    end

    def test_working_project
      Roger::Generators.register ::Generators::MockedWithProjectGenerator
      generators = Cli::Generate.new

      assert_raise StandardError do
        generators.invoke "mockedwithproject"
      end
    end

    def test_register_generator
      Roger::Generators.register ::Generators::MockedGenerator
      assert_includes Cli::Generate.tasks, "mocked"
      assert_equal Cli::Generate.tasks["mocked"].description, "@mocked description"
      assert_equal Cli::Generate.tasks["mocked"].usage, "mocked PATH ANOTHER_ARG"
    end

    def test_register_generator_with_custom_name
      Roger::Generators.register :mockery, ::Generators::MockedGenerator
      assert_includes Cli::Generate.tasks, "mockery"
    end

    def test_cli_help_shows_all_available_generators
    end

    def test_invoke_mocked_generator
      Roger::Generators.register ::Generators::MockedGenerator

      generators = Cli::Generate.new
      assert_raise NotImplementedError do
        generators.invoke :mocked
      end
    end
  end
end
