# Generators register themself on the CLI module
require "test_helper"
require "roger/testing/mock_project"

class MockupFileLoadedError < StandardError
end

module Roger
  # Test Roger Release
  class ReleaseTest < ::Test::Unit::TestCase
    def setup
      @project = Testing::MockProject.new
    end

    def teardown
      @project.destroy
    end

    def test_load_mockupfile
      @project.construct.file "Mockupfile", "raise MockupFileLoadedError"

      mockupfile = Roger::Mockupfile.new(@project)

      assert_raise(MockupFileLoadedError) do
        mockupfile.load
      end
    end

    def test_loaded_mockupfile
      @project.construct.file "Mockupfile", ""

      mockupfile = Roger::Mockupfile.new(@project)
      mockupfile.load

      assert mockupfile.loaded?
    end
  end
end
