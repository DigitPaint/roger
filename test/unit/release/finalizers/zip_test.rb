require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test for Roger Zip finalizer
  class ZipTest < ::Test::Unit::TestCase
    def setup
      @release = Testing::MockRelease.new

      # Create a file to release in the build dir
      @release.project.construct.file "build/index.html"

      # Set fixed version
      @release.scm.version = "1.0.0"
    end

    # called after every single test
    def teardown
      @release.destroy
      @release = nil
    end

    def test_basic_functionality
      finalizer = Roger::Release::Finalizers::Zip.new

      finalizer.call(@release)

      assert File.exist?(@release.target_path + "html-1.0.0.zip"), @release.target_path.inspect
    end
  end
end
