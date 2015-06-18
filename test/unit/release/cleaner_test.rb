require "test_helper"
require "./lib/roger/release"
require "./lib/roger/release/cleaner"

module Roger
  # Test Roger Cleaner
  class CleanerTest < ::Test::Unit::TestCase
    def setup
      @base = File.dirname(__FILE__) + "/../../project"
    end

    def test_use_array_as_pattern
      dirs = %w(dir1 dir2)

      create_and_assert_directories(dirs)

      project = Roger::Project.new(@base)
      release = Roger::Release.new(project, build_path: Pathname.new(@base))

      cleaner = Roger::Release::Cleaner.new(dirs)
      cleaner.call(release)

      dirs.each do |dir|
        path = @base + "/" + dir
        assert(!File.directory?(path))
      end
    end

    def test_only_clean_inside_build_path_relative
      cleaner = Roger::Release::Cleaner.new(@base)
      inside_build_path = cleaner.send :inside_build_path?, @base, @base + "/html/formats"

      assert(inside_build_path, "Only delete content inside build_path")
    end

    def test_only_clean_inside_build_path_absolute
      path = Pathname.new(@base).realpath.to_s
      cleaner = Roger::Release::Cleaner.new(path)

      inside_build_path = cleaner.send :inside_build_path?, path, @base + "/html/formats"

      assert(inside_build_path, "Only delete content inside build_path")
    end

    def test_dont_clean_outside_build_path
      path = File.dirname(__FILE__)
      cleaner = Roger::Release::Cleaner.new(path)

      assert_raise RuntimeError do
        cleaner.send :inside_build_path?, path, @base + "/html/formats"
      end
    end

    def test_dont_fail_on_nonexistent_files
      path = "bla"
      cleaner = Roger::Release::Cleaner.new(path)

      assert(
        !cleaner.send(:inside_build_path?, @base + "/html/formats", path),
        "Failed on nonexistent directories/files"
      )
    end

    protected

    def create_and_assert_directories(dirs)
      dirs.each do |dir|
        path = @base + "/" + dir
        mkdir path unless File.directory?(path)
        assert(File.directory?(path))
      end
    end
  end
end
