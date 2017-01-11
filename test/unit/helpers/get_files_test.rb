require "test_helper"
require "test_construct"
require "./lib/roger/helpers/get_files"

# Empty class that uses getfiles
# This is outside of the Roger namespace by design.
class MyGetFiles
  include TestConstruct::Helpers
  include Roger::Helpers::GetFiles

  attr_accessor :construct

  def initialize
    @construct = setup_construct
  end

  def destroy
    teardown_construct(construct)
  end

  protected

  def get_files_default_path
    construct
  end
end

module Roger
  # Test GetFiles module
  class GetFilesTest < ::Test::Unit::TestCase
    def setup
      @object = MyGetFiles.new

      files = [
        "a.js",
        "1.js",
        "1.html",
        "dir/2.js",
        "dir/3.js",
        "dir/subdir/4.js"
      ]

      @files = files.map do |file|
        @object.construct.file(file).to_s
      end
    end

    def teardown
      @object.destroy
    end

    def test_glob
      files = @object.get_files(["**/*.js"])
      expect = @files.grep(/\.js\Z/)
      assert_array_contains(expect, files)
    end

    def test_get_only_files
      dir = @object.construct.directory "evil.js"
      files = @object.get_files(["*.js"])
      assert_not_include files, dir.to_s
    end

    def test_excludes
      files = @object.get_files(["**/*.js"], ["\Adir"])
      expect = @files.grep(/\.js\Z/).reject { |f| f.start_with?("dir") }
      assert_array_contains(expect, files)
    end

    protected

    def assert_array_contains(expect, result)
      assert expect.size == result.size && expect & result == expect
    end
  end
end
