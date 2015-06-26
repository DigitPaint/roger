# Generators register themself on the CLI module
require "test_helper"
require "roger/testing/mock_project"

module Roger
  # Test Roger Release
  class ReleaseTest < ::Test::Unit::TestCase
    def setup
      @project = Testing::MockProject.new
      @mockupfile = Roger::Mockupfile.new(@project)
    end

    def test_run_should_set_project_mode
      assert_equal @project.mode, nil

      # Running a blank release
      @mockupfile.release(blank: true) do |r|
        r.use proc{|release|
          assert_equal release.project.mode, :release
        }
      end

      @project.release.run!
      assert_equal @project.mode, nil
    end

    def test_blank_release_should_have_no_processors_and_finalizers
      @mockupfile.release(blank: true)
      @project.release.run!

      assert @project.release.stack.empty?
      assert @project.release.finalizers.empty?
    end

    def test_get_callable
      p = -> {}
      assert_equal Release.get_callable(p, {}), p
      assert_raise(ArgumentError) { Release.get_callable(nil, {}) }
    end

    def test_get_callable_with_map
      p = -> {}
      map = {
        lambda: p
      }

      assert_equal Release.get_callable(:lambda, map), p
      assert_raise(ArgumentError) { Release.get_callable(:huh, map) }
    end

    # A Release class that is valid
    class Works
      def call; end
    end

    # A Release class that is invalid
    class Breaks
    end

    def test_get_callable_with_class
      assert Release.get_callable(Works, {}).instance_of?(Works)
      assert_raise(ArgumentError) { Release.get_callable(Breaks, {}) }
    end
  end
end
