module Roger
  class Cli::Test < Thor
    def self.exit_on_failure?
      true
    end

    default_task :all    

    desc "all", "Run all tests defined in Mockupfile. (this is the default action)"
    def all
      unless Cli::Base.project.test.run!
        raise Thor::Error, "Test failed"
      end
    end
  end
end