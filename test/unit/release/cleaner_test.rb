require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test Roger Cleaner
  class CleanerTest < ::Test::Unit::TestCase
    def setup
      @release = Testing::MockRelease.new
    end

    def teardown
      @release.destroy
      @release = nil
    end

    def test_use_array_as_pattern
      dirs = %w(dir1 dir2)

      dirs.each do |dir|
        @release.project.construct.directory "build/#{dir}"
      end

      cleaner = Roger::Release::Cleaner.new(dirs)
      cleaner.call(@release)

      dirs.each do |dir|
        path = @release.build_path + dir
        assert(!File.directory?(path))
      end
    end

    def test_only_clean_inside_build_path_relative
      project_path = @release.project.path
      cleaner = Roger::Release::Cleaner.new(project_path)
      inside = cleaner.send :inside_build_path?, project_path, project_path + "html"

      assert(inside, "Only delete content inside build_path")
    end

    def test_only_clean_inside_build_path_absolute
      project_path = @release.project.path
      path = Pathname.new(project_path).realpath.to_s
      cleaner = Roger::Release::Cleaner.new(path)

      inside = cleaner.send :inside_build_path?, path, project_path + "html"

      assert(inside, "Only delete content inside build_path")
    end

    def test_dont_clean_outside_build_path
      path = File.dirname(__FILE__)
      cleaner = Roger::Release::Cleaner.new(path)

      assert_raise RuntimeError do
        cleaner.send :inside_build_path?, path, @release.project.path + "html"
      end
    end

    def test_dont_fail_on_nonexistent_files
      path = "bla"
      cleaner = Roger::Release::Cleaner.new(path)

      assert(
        !cleaner.send(:inside_build_path?, @release.project.path + "/html", path),
        "Failed on nonexistent directories/files"
      )
    end
  end
end
