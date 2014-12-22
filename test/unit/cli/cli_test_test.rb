require "./lib/roger/cli.rb"
require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../../project/lib/tests/fail/fail"
require File.dirname(__FILE__) + "/../../project/lib/tests/succeed/succeed"
require File.dirname(__FILE__) + "/../../project/lib/tests/noop/noop"

# These tests ar for the roger test command

module Roger
  class CliTestTest < ::Test::Unit::TestCase

    def setup
      @base_path = File.dirname(__FILE__) + "/../../project"
    end


    # Capture stdout/stderr output
    def capture
      @_orig_stdout, @_orig_stderr = $stdout, $stderr
      
      $stdout = StringIO.new
      $stderr = StringIO.new

      yield

      return [$stdout.string, $stderr.string]
    ensure
      $stdout, $stderr = @_orig_stdout, @_orig_stderr
    end

    def run_test_command(args, &block)
      project = Project.new(@base_path, :mockupfile_path => false)

      mockupfile = Roger::Mockupfile.new(project)

      if block_given?
        mockupfile.test(&block)
      else
        mockupfile.test do |t|
          t.use :succeed
          t.use :noop
        end
      end

      project.mockupfile = mockupfile

      Cli::Base.project = project

      capture do
        Cli::Base.start(args, :debug => true)
      end
    end

    def test_has_subcommand_all
      assert_includes Cli::Base.tasks.keys, "test"
    end

    # roger test all
    def test_subcommand_all_runs_all_tests
      out, err = run_test_command %w{test all}
      assert_includes out, "RogerNoopTest::Test"
      assert_includes out, "RogerSucceedTest::Test"
    end

    def test_subcommand_all_runs_all_tests_in_order_1
      out, err = run_test_command %w{test all} do |t|
        t.use :succeed
        t.use :noop
      end
      assert out.index("RogerNoopTest::Test") > out.index("RogerSucceedTest::Test") 
    end    

    def test_subcommand_all_runs_all_tests_in_order_2
      out, err = run_test_command %w{test all} do |t|
        t.use :noop
        t.use :succeed        
      end
      assert out.index("RogerSucceedTest::Test") > out.index("RogerNoopTest::Test") 
    end

    # roger test
    def test_default_runs_all_tests
      out, err = run_test_command %w{test}
      assert_includes out, "RogerNoopTest::Test"
      assert_includes out, "RogerSucceedTest::Test"
    end

    # roger help test
    def test_help_shows_available_subcommands
      out, err = run_test_command %w{help test}
      assert_includes out, "test all"
      assert_includes out, "test succeed"
      assert_includes out, "test noop"
    end

    # roger test noop
    def test_subcommand_x_runs_only_test_x
      out, err = run_test_command %w{test noop}      
      assert_includes out, "RogerNoopTest::Test"
      assert_not_includes out, "RogerSucceedTest::Test"
    end

    def test_subcommand_x_has_exit_code_1_on_failure
      assert_raise(Thor::Error) do
        out, err = run_test_command %w{test fail} do |t|
          t.use :noop
          t.use :fail
        end
      end
    end

    def test_subcommand_x_has_exit_code_0_on_success
      assert_nothing_raised do
        out, err = run_test_command %w{test noop} do |t|
          t.use :noop
          t.use :fail
        end
      end      
    end

    def test_subcommand_all_has_exit_code_1_on_failure
      assert_raise(Thor::Error) do
        out, err = run_test_command %w{test} do |t|
          t.use :noop
          t.use :fail
        end
      end
    end

    def test_subcommand_all_has_exit_code_0_on_success
      assert_nothing_raised do
        out, err = run_test_command %w{test} do |t|
          t.use :noop
          t.use :succeed
        end
      end         
    end

  end
end