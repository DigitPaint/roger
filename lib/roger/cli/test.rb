module Roger
  class Cli::Test < Thor
    default_task :test

    desc "test", "run tests"
    def test
      puts "Running all tests"
    end
  end
end