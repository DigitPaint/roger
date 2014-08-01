module Roger
  module Test
    module Noop
      class Cli < Roger::Test::Cli
        default_task :test

        desc "test", "run noop tests"
        def test
          test = Test.new
          test.run!
        end

        desc "init", "init noop tests"
        def init
          puts "you could init stuff here"
        end
      end
    end
  end
end