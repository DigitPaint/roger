require "test_helper"
require "./lib/roger/cli"

module Roger
  # Just a noop command class for testing
  class CliNoop < Cli::Command
  end

  # Open existing Cli::Base to add Noop method.
  class Cli::Base < Thor
    register(
      CliNoop,
      "noop",
      "noop",
      "noop"
    )
    tasks["noop"].options = Cli::Serve.class_options
  end
end

module Roger
  # Test for roger base commands
  class CliBaseTest < ::Test::Unit::TestCase
    include TestCli

    def teardown
      Cli::Base.project = nil
    end

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

    # Option passing

    def test_pass_options_to_project
      run_command(%w(noop --path=henk))
      assert_equal "henk", Cli::Base.project.options[:path]
    end

    def test_pass_roger_options_to_project
      run_command(%w(noop --some_option=henk))
      assert_equal "henk", Cli::Base.project.options[:some_option]
    end

    def test_pass_multiple_roger_options_to_project
      run_command(%w(noop --option1=henk --option2=henk))
      assert_equal "henk", Cli::Base.project.options[:option1]
      assert_equal "henk", Cli::Base.project.options[:option2]
    end

    def test_pass_roger_options_without_equal_to_project
      run_command(%w(noop --option1 henk --option2 pino))
      assert_equal "henk", Cli::Base.project.options[:option1]
      assert_equal "pino", Cli::Base.project.options[:option2]
    end

    def test_pass_roger_nested_options_to_project
      run_command(%w(noop --level0:level1=henk))
      assert_equal "henk", Cli::Base.project.options[:level0][:level1]
    end

    def test_pass_boolean_roger_options_to_project
      run_command(%w(noop --istrue))
      assert_equal true, Cli::Base.project.options[:istrue]
    end

    def test_pass_boolean_literal_true_roger_options_to_project
      run_command(%w(noop --istrue=true))
      assert_equal true, Cli::Base.project.options[:istrue]
    end

    def test_pass_boolean_literal_false_roger_options_to_project
      run_command(%w(noop --isfalse=false))
      assert_equal false, Cli::Base.project.options[:isfalse]
    end
  end
end
