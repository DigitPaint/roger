# encoding: UTF-8
require "test/unit"
require "mocha/test_unit"
require "./lib/roger/test.rb"

module Roger
  class TestTest < ::Test::Unit::TestCase
    def setup
      @files = ["html/javascripts/site.js",
                "html/vendor/underscore/underscore.js"]
      @globs = stub(map: @files)
    end

    def test_get_files
      test = Roger::Test.new({})
      assert_equal(test.get_files(@globs), @files)
    end

    def test_get_files_excludes
      test = Roger::Test.new({})
      assert_equal(test.get_files(@globs, ["html\/vendor\/.+.js"]),
                   ["html/javascripts/site.js"])
    end
  end
end
