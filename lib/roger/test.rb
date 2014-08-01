require 'thor'

module Roger
  module Test

    class Cli < Thor
    end

    def self.register(name, klass)

      long_desc = "Run #{name} tests"

      if klass <= Roger::Test::Cli 
        usage = "#{name} #{klass.arguments.map{ |arg| arg.banner }.join(" ")}"
        thor_class = klass
      else
        usage = "test"
        thor_class = Class.new(Roger::Test::Cli) do
          default_task :test

          @@klass = klass

          desc "test", "run tests"
          def test
            @@klass.new.run!
          end
        end
      end

      Roger::Cli::Test.register thor_class, name, usage, long_desc

    end

  end
end

require File.dirname(__FILE__) + "/test/noop/noop"