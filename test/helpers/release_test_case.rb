require "test_construct"

require "roger/release"

require File.dirname(__FILE__) + "/project_test_case"

module Roger
  # The Release test case sets up paths
  # and a build_path which is a test_construct
  # so you can build arbitrary build directories and run your processors on them.
  #
  # It will not create a build_path construct if the project itself is already a construct
  class ReleaseTestCase < ProjectTestCase
    attr_accessor :build_path, :release

    # Default setup with set's up:
    #
    # @build_path
    def setup
      super

      if self.class.use_blank_project
        @build_path = project.path + "build"
      else
        @build_path = setup_construct
      end

      @release = Roger::Release.new(project, build_path: @build_path)
    end

    def teardown
      teardown_construct(@build_path) unless self.class.use_blank_project

      super
    end
  end
end
