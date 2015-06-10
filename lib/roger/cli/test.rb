module Roger
  class Cli::Test < Thor
    def self.exit_on_failure?
      true
    end

    default_task :all

    desc "all", "Run all tests defined in Mockupfile. (this is the default action)"
    def all
      raise(Thor::Error, "Test failed") unless Cli::Base.project.test.run!
    end
  end
end
