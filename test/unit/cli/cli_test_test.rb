require "./lib/roger/cli.rb"
require "test/unit"

require File.dirname(__FILE__) + "/../../helpers/cli"

require File.dirname(__FILE__) + "/../../project/lib/tests/fail/fail"
require File.dirname(__FILE__) + "/../../project/lib/tests/succeed/succeed"
require File.dirname(__FILE__) + "/../../project/lib/tests/noop/noop"

# These tests ar for the roger test command

module Roger
  class CliTestTest < ::Test::Unit::TestCase
    include TestCli

    def teardown
      Cli::Base.project = nil
    end

    def run_test_command(args, &block)
      run_command_with_mockupfile(args) do |mockupfile|
        if block_given?
          mockupfile.test(&block)
        else
          mockupfile.test do |t|
            t.use :succeed
            t.use :noop
          end
        end
      end
    end

    def test_has_subcommand_all
      assert_includes Cli::Base.tasks.keys, "test"
    end

    # roger test all
    def test_subcommand_all_runs_all_tests
      out, err = run_test_command %w(test all)
      assert_includes out, "RogerNoopTest::Test"
      assert_includes out, "RogerSucceedTest::Test"
    end

    def test_subcommand_all_runs_all_tests_in_order_1
      out, err = run_test_command %w(test all) do |t|
        t.use :succeed
        t.use :noop
      end
      assert out.index("RogerNoopTest::Test") > out.index("RogerSucceedTest::Test")
    end

    def test_subcommand_all_runs_all_tests_in_order_2
      out, err = run_test_command %w(test all) do |t|
        t.use :noop
        t.use :succeed
      end
      assert out.index("RogerSucceedTest::Test") > out.index("RogerNoopTest::Test")
    end

    # roger test
    def test_default_runs_all_tests
      out, err = run_test_command %w(test)
      assert_includes out, "RogerNoopTest::Test"
      assert_includes out, "RogerSucceedTest::Test"
    end

    # roger test -v
    def test_has_option_v
      # A somewhat a-typical test,
      # just to make it work
      cli = ::Roger::Cli::Base.new [], %w(--verbose)
      cli.class.project.mockupfile.test do |t|
        t.use :noop
      end

      out, _err = capture do
        cli.invoke "test"
      end

      assert_includes out, "NOOP DEBUG", out
    end

    # roger help test
    def test_help_shows_available_subcommands
      out, err = run_test_command %w(help test)
      assert_includes out, "test all"
      assert_includes out, "test succeed"
      assert_includes out, "test noop"
    end

    # roger test noop
    def test_subcommand_x_runs_only_test_x
      out, err = run_test_command %w(test noop)
      assert_includes out, "RogerNoopTest::Test"
      assert_not_includes out, "RogerSucceedTest::Test"
    end

    def test_subcommand_x_has_exit_code_1_on_failure
      assert_raise(Thor::Error) do
        out, err = run_test_command %w(test fail) do |t|
          t.use :noop
          t.use :fail
        end
      end
    end

    def test_subcommand_x_has_exit_code_0_on_success
      assert_nothing_raised do
        out, err = run_test_command %w(test noop) do |t|
          t.use :noop
          t.use :fail
        end
      end
    end

    def test_subcommand_all_has_exit_code_1_on_failure
      assert_raise(Thor::Error) do
        out, err = run_test_command %w(test) do |t|
          t.use :noop
          t.use :fail
        end
      end
    end

    def test_subcommand_all_has_exit_code_0_on_success
      assert_nothing_raised do
        out, err = run_test_command %w(test) do |t|
          t.use :noop
          t.use :succeed
        end
      end
    end
  end
end
