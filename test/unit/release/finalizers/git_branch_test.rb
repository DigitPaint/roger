require File.dirname(__FILE__) + "/../../../helpers/release_test_case"

require "mocha/test_unit"

module Roger
  # Test for Roger GitBranchFinalizer
  class GitBranchTest < ReleaseTestCase
    self.use_blank_project = true

    def setup
      super

      Dir.chdir(project_path.to_s) do
        `git init`
      end

      # Creating a file in build so it will be finalized
      project_path.file "build/index.html"

      # We're stubbing the scm so we always get the same version.
      release.stubs(
        scm: stub(version: "1.0.0")
      )
    end

    def test_basic_functionality
      git_branch_finalizers = Roger::Release::Finalizers::GitBranch.new

      output_dir = git_branch_finalizers.call(
        release,
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
  end
end
