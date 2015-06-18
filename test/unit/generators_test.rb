# Generators register themself on the CLI module
require "./lib/roger/generators.rb"
require "test/unit"

module CustomGens
  module Generators
    # Simple Mock generator
    class MockedGenerator < Roger::Generators::Base
      desc "@mocked description"
      argument :path, type: :string, required: false, desc: "Path to generate mockup into"
      argument :another_arg, type: :string, required: false, desc: "Mocked or what?!"

      def test
        # Somewhat ugly way of checking
        fail NotImplementedError
      end
    end

    # Simple Mocku generator that has a project
    class MockedWithProjectGenerator < Roger::Generators::Base
      desc "Returns a project"
      def test
        # Somewhat ugly way of checking
        fail StandardError if @project
      end
    end
  end
end

module Roger
  # Test Roger Generators
  class GeneratorTest < ::Test::Unit::TestCase
    def setup
      @cli = Cli::Base.new

      # Dirty hack to clean up tasks
      Cli::Generate.tasks.delete("mocked")
      Cli::Generate.tasks.delete("mockery")
    end

    def test_working_project
      Roger::Generators.register CustomGens::Generators::MockedWithProjectGenerator
      generators = Cli::Generate.new

      assert_raise StandardError do
        generators.invoke "mockedwithproject"
      end
    end

    def test_register_generator
      Roger::Generators.register CustomGens::Generators::MockedGenerator
      assert_includes Cli::Generate.tasks, "mocked"
      assert_equal Cli::Generate.tasks["mocked"].description, "@mocked description"
      assert_equal Cli::Generate.tasks["mocked"].usage, "mocked PATH ANOTHER_ARG"
    end

    def test_register_generator_with_custom_name
      Roger::Generators.register :mockery, CustomGens::Generators::MockedGenerator
      assert_includes Cli::Generate.tasks, "mockery"
    end

    def test_cli_help_shows_all_available_generators
    end

    def test_default_generator
      assert_includes Cli::Generate.tasks, "new"
    end

    def test_generator_generator
      generators = Cli::Generate.new
      name = "tralal"
      path = "./tmp"
      generators.invoke :generator, [name, path]
      assert File.exist? "#{path}/#{name}_generator.rb"

      # Remove generated generator
      File.unlink "#{path}/#{name}_generator.rb"
    end

    def test_invoke_mocked_generator
      Roger::Generators.register CustomGens::Generators::MockedGenerator

      generators = Cli::Generate.new
      assert_raise NotImplementedError do
        generators.invoke :mocked
      end
    end
  end
end
