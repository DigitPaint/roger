require File.dirname(__FILE__) + "/../../helpers/release_test_case"
require "test/unit"

module Roger
  # Test Roger Cleaner
  class CleanerTest < ReleaseTestCase
    def test_use_array_as_pattern
      dirs = %w(dir1 dir2)

      dirs.each do |dir|
        build_path.directory dir
      end

      cleaner = Roger::Release::Cleaner.new(dirs)
      cleaner.call(release)

      dirs.each do |dir|
        path = build_path + dir
        assert(!File.directory?(path))
      end
    end

    def test_only_clean_inside_build_path_relative
      cleaner = Roger::Release::Cleaner.new(project_path)
      inside = cleaner.send :inside_build_path?, project_path, project_path + "/html/formats"

      assert(inside, "Only delete content inside build_path")
    end

    def test_only_clean_inside_build_path_absolute
      path = Pathname.new(project_path).realpath.to_s
      cleaner = Roger::Release::Cleaner.new(path)

      inside = cleaner.send :inside_build_path?, path, project_path + "/html/formats"

      assert(inside, "Only delete content inside build_path")
    end

    def test_dont_clean_outside_build_path
      path = File.dirname(__FILE__)
      cleaner = Roger::Release::Cleaner.new(path)

      assert_raise RuntimeError do
        cleaner.send :inside_build_path?, path, project_path + "/html/formats"
      end
    end

    def test_dont_fail_on_nonexistent_files
      path = "bla"
      cleaner = Roger::Release::Cleaner.new(path)

      assert(
        !cleaner.send(:inside_build_path?, project_path + "/html/formats", path),
        "Failed on nonexistent directories/files"
      )
    end
  end
end
