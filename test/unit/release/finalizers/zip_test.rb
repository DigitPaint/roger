require File.dirname(__FILE__) + "/../../../helpers/release_test_case"

require "mocha/test_unit"

module Roger
  # Test for Roger Zip finalizer
  class ZipTest < ReleaseTestCase
    self.use_blank_project = true

    def setup
      super

      Dir.chdir(project_path.to_s) do
        `git init`
      end

      project_path.file "build/index.html"

      # We're stubbing the scm so we always get the same version.
      release.stubs(
        scm: stub(version: "1.0.0")
      )
    end

    # called after every single test
    def teardown
      super
    end

    def test_basic_functionality
      finalizer = Roger::Release::Finalizers::Zip.new

      finalizer.call(release)

      assert File.exist?(release.target_path + "html-1.0.0.zip")
    end
  end
end
