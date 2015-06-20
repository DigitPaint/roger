require File.dirname(__FILE__) + "/mock_project"

module Roger
  module Testing
    # Creates a mock release object. It is the same as a regular release
    # with the following "presets"
    #
    # - it will automatically use the :fixed SCM
    # - it will automatically initialize a MockProject if you don't
    #   pass a project to the initializer
    #
    # Use MockRelease in testing but never forget to call:
    #
    #     MockRelease#destroy
    #
    # in teardown otherwise you pollute your filesystem with build directories
    #
    class MockRelease < Release
      def initialize(project = nil, config = {})
        config = {
          scm: :fixed
        }.update(config)

        unless project
          # Create a mock project that's completely empty
          project = MockProject.new
        end

        # Call super to initialize
        super(project, config)
      end

      # Destroy will remove all files/directories
      def destroy
        project.destroy if project.is_a?(MockProject)
      end
    end
  end
end
