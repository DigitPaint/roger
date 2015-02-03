module Roger

  class Cli::Command < Thor::Group
    def self.exit_on_failure?
      true
    end


    def initialize_project
      @project = Cli::Base.project
    end

    protected

    def project_banner(project)
      puts "  Html: \"#{project.html_path}\""
      puts "  Partials: \"#{project.partial_path}\""
    end
  end

end