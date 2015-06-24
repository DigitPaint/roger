# encoding: UTF-8
require "test_helper"
require "./lib/roger/test.rb"
require "roger/testing/mock_project"

module Roger
  # Testing the Roger Test fucntionality
  class TestTest < ::Test::Unit::TestCase
    def setup
      @files = ["html/javascripts/site.js",
                "html/vendor/underscore/underscore.js"]

      @project = Testing::MockProject.new

      @files.each do |file|
        @project.construct.file file
      end

      @mockupfile = Roger::Mockupfile.new(@project)
    end

    def teardown
      @project.destroy
    end

    def test_test_run_should_set_project_mode
      assert_equal @project.mode, nil

      @mockupfile.test do |t|
        t.use proc{|test|
          assert_equal test.project.mode, :test
        }
      end

      @project.test.run!
      assert_equal @project.mode, nil
    end

    def test_get_files
      test = Roger::Test.new(@project)
      files = test.get_files(["html/**/*.js"])
      assert_equal(clean_paths(files, @project.path), @files)
    end

    def test_get_files_excludes
      test = Roger::Test.new(@project)
      files = test.get_files(["html/**/*.js"], ["html\/vendor\/.+.js"])
      assert_equal(clean_paths(files, @project.path), ["html/javascripts/site.js"])
    end

    protected

    # Clean's path, chops of base
    def clean_paths(paths, base)
      paths.map do |file|
        file.gsub(%r{\A#{base}/}, "")
      end
    end
  end
end
