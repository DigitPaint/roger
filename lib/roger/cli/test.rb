module Roger
  # The test command and all it's children
  class Cli::Test < Thor
    def self.exit_on_failure?
      true
    end

    default_task :all

    desc "all", "Run all tests defined in Rogerfile. (this is the default action)"
    def all
      raise(Thor::Error, "Test failed") unless Cli::Base.project.test.run!
    end
  end
end
