# Generators register themself on the CLI module
require "test_helper"
require "roger/testing/mock_project"

class RogerfileLoadedError < StandardError
end

module Roger
  # Test Roger Release
  class MockupFileTest < ::Test::Unit::TestCase
    def setup
      @project = Testing::MockProject.new
    end

    def teardown
      @project.destroy
    end

    def test_load_rogerfile
      @project.construct.file "Rogerfile", "raise RogerfileLoadedError"

      rogerfile = Roger::Rogerfile.new(@project)

      assert_raise(RogerfileLoadedError) do
        rogerfile.load
      end
    end

    def test_loaded_rogerfile
      @project.construct.file "Rogerfile", ""

      rogerfile = Roger::Rogerfile.new(@project)
      rogerfile.load

      assert rogerfile.loaded?
    end
  end
end
