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

      @project = Project.new(File.dirname(__FILE__) + "/../project", :mockupfile_path => false)
      @mockupfile = Roger::Mockupfile.new(@project)
    end

    def test_test_run_should_set_project_mode
      assert_equal @project.mode, nil

      @mockupfile.test do |t|
        t.use Proc.new{|test|
          assert_equal test.project.mode, :test
        }
      end

      @project.test.run!
      assert_equal @project.mode, nil
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
