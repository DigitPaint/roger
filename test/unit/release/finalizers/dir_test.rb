require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test for Roger DirFinalizer
  class DirFinalizerTest < ::Test::Unit::TestCase
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
      finalizer = Roger::Release::Finalizers::Dir.new

      finalizer.call(@release)

      assert File.exist?(@release.target_path + "html-1.0.0"), @release.target_path.inspect
      assert File.directory?(@release.target_path + "html-1.0.0"), @release.target_path.inspect
    end

    def test_cleanup_existing_dir
      dir = @release.project.construct.directory("releases/html-1.0.0")

      finalizer = Roger::Release::Finalizers::Dir.new

      original_ctime = File.ctime(dir)

      finalizer.call(@release)

      assert_not_same original_ctime, File.ctime(dir)
    end

    def test_target_path
      finalizer = Roger::Release::Finalizers::Dir.new
      dir = @release.project.construct.directory("rel")

      finalizer.call(@release, target_path: dir)

      assert File.exist?(dir + "html-1.0.0")
    end

    def test_target_path_with_string
      finalizer = Roger::Release::Finalizers::Dir.new
      dir = @release.project.construct.directory("rel")

      finalizer.call(@release, target_path: dir.to_s)

      assert File.exist?(dir + "html-1.0.0")
    end

    def test_target_path_will_be_created_if_nonexistent
      finalizer = Roger::Release::Finalizers::Dir.new
      dir = @release.target_path + "rel"

      finalizer.call(@release, target_path: dir)

      assert File.exist?(dir + "html-1.0.0")
    end
  end
end
