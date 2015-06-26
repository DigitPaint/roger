require "test_helper"
require "roger/testing/mock_release"
require "shellwords"

module Roger
  # Test for Roger GitBranchFinalizer
  class GitBranchTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers

    def setup
      @release = Testing::MockRelease.new

      # Create a file to release in the build dir
      @release.project.construct.file "build/index.html"

      # Set fixed version
      @release.scm.version = "1.0.0"
    end

    def teardown
      @release.destroy
      @release = nil
    end

    def test_basic_functionality
      git_branch_finalizers = Roger::Release::Finalizers::GitBranch.new

      output_dir = git_branch_finalizers.call(
        @release,
        remote: "http://we.aint.go/nna.push.git",
        push: false,
        cleanup: false
      )

      Dir.chdir(output_dir + "clone") do
        commit_msg = `git log --pretty=oneline --abbrev-commit`
        assert_match(/Release 1.0.0/, commit_msg)
      end

      FileUtils.rm_rf(output_dir)
    end

    def test_find_remote
      finalizer = Roger::Release::Finalizers::GitBranch.new
      remote_repo = setup_construct(chdir: false)

      `git init`

      Dir.chdir(remote_repo.to_s) do
        `git init --bare`
      end

      `git remote add origin #{Shellwords.escape(remote_repo.to_s)}`

      assert_nothing_raised do
        finalizer.call(
          @release,
          push: false,
          cleanup: false
        )
      end
    ensure
      teardown_construct(remote_repo)
    end
  end
end
