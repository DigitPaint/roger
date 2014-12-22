module Roger

  class Cli::Command < Thor::Group
    def self.exit_on_failure?
      true
    end
    
    class_option :verbose,
      :desc =>  "Set's verbose output",
      :aliases => ["-v"],
      :default => false,
      :type => :boolean


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