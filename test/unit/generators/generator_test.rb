# encoding: UTF-8

# Generators register themself on the CLI module
require "test_helper"
require "test_construct"

require File.dirname(__FILE__) + "/../../helpers/cli"

module Roger
  # Test Roger Generators
  class GeneratoGeneratorTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers
    include TestCli

    def test_new_generator_exists
      assert_includes Cli::Generate.tasks, "generator"
    end

    def test_generator_generator
      name = "tralal"
      path = "./tmp"

      within_construct do
        run_command(%w(generate generator) + [name, path])
        assert File.exist? "#{path}/#{name}_generator.rb"
      end
    end
  end
end
