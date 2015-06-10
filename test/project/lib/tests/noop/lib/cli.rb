module RogerNoopTest
  # A CLI command for the Noop test. Doesn't do anything, just output "initialized"
  class Cli < Roger::Test::Cli
    desc "init", "init noop tests"
    def init
      puts "initialized"
    end
  end
end
