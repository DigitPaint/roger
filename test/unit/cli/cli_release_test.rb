require "test_helper"
require "./lib/roger/cli"
require "test_construct"

require File.dirname(__FILE__) + "/../../helpers/cli"

module Roger
  # These tests ar for the roger generate command
  class CliReleaseTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers
    include TestCli

    def setup
      # Reset project as not to leak from other tests
      Cli::Base.project = nil

      @base_path = setup_construct
      @base_path.directory "html" do |h|
        h.file "index.html"
      end
      @base_path.file "Rogerfile", "roger.release(scm: :fixed) { |r| r.scm.version = '1' }"
    end

    def teardown
      teardown_construct(@base_path)
      Cli::Base.project = nil
    end

    # roger generate
    def test_has_release_command
      assert_includes Cli::Base.tasks.keys, "release"
    end

    def test_runs_release
      run_command(%w(release))
      assert File.exist?(@base_path + "releases/html-1")
    end
  end
end
