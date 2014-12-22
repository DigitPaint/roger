module RogerNoopTest
  class Cli < Roger::Test::Cli
    desc "init", "init noop tests"
    def init
      puts "initialized"
    end
  end
end