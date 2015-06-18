require "test_helper"
require "./lib/roger/release/finalizers/git_branch"
require "tmpdir"

module Roger
  # Test for Roger GitBranchFinalizer
  class GitBranchTest < ::Test::Unit::TestCase
    def setup
      # Mock git repo
      @tmp_dir = Pathname.new(Dir.mktmpdir)
      mock_repo_path = @tmp_dir + "mock_repo"
      FileUtils.mkdir(mock_repo_path)
      Dir.chdir(mock_repo_path) do
        `git init`
        `mkdir releases`
        `touch releases/index.html`
      end

      # Mock release object
      @release_mock = stub(project: stub(path: mock_repo_path))

      @release_mock.stubs(
        scm: stub(version: "0.1.999"),
        log: true,
        build_path: mock_repo_path.to_s + "/releases"
      )
    end

    # called after every single test
    def teardown
      FileUtils.rm_rf(@tmp_dir)
      @release_mock = nil
    end

    def test_basic_functionality
      git_branch_finalizers = Roger::Release::Finalizers::GitBranch.new

      output_dir = git_branch_finalizers.call(
        @release_mock,
        remote: "http://we.aint.go/nna.push.git",
        push: false,
        cleanup: false
      )

      Dir.chdir(output_dir + "clone") do
        commit_msg = `git log --pretty=oneline --abbrev-commit`
        assert_match(/Release 0.1.999/, commit_msg)
      end

      FileUtils.rm_rf(output_dir)
    end
  end
end
