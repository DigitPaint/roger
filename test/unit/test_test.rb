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
  end
end
