require "test/unit"

require "roger/project"

module Roger
  # The project test case sets up paths and projects for your convenience
  class ProjectTestCase < ::Test::Unit::TestCase
    include TestConstruct::Helpers

    class << self
      attr_accessor :use_blank_project
    end

    # Attribute accessors for project specific variables
    attr_accessor :project_path, :project

    # Default setup with set's up:
    #
    # If self.class.use_ficture_project == true will use the project path;
    # otherwise will set up a blank project.
    #
    # @project_path
    # @project
    def setup
      if self.class.use_blank_project
        @project_path = setup_construct

        setup_empty_project

        @project = Roger::Project.new(@project_path)
      else
        @project_path = File.dirname(__FILE__) + "/../project"
        @project = Roger::Project.new(@project_path)
      end
    end

    def teardown
      teardown_construct(@project_path) if self.class.use_blank_project
    end

    def setup_empty_project
      puts "EMPTY PROJECT"
      %w(html partials layouts releases).each do |dir|
        @project_path.directory dir
      end
    end
  end
end
