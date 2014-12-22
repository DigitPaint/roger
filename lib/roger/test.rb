require File.dirname(__FILE__) + "/helpers/get_callable"
require File.dirname(__FILE__) + "/helpers/logging"

module Roger
  class Test
    class Cli < Thor
      def self.exit_on_failure?
        true
      end
    end

    include Roger::Helpers::Logging

    attr_reader :config, :project

    class << self
      include Roger::Helpers::GetCallable

      def register(name, test)
        raise ArgumentError, "Another test has already claimed the name #{name.inspect}" if self.map.has_key?(name)
        raise ArgumentError, "Name must be a symbol" unless name.kind_of?(Symbol)
        self.map[name] = test
      end

      # Mapping names to test callers
      def map
        @_map ||= {}
      end

      # Mapping names to CLI handlers (this gives the option to add custom subcommands like 'init')
      def cli_map
        @_cli_map ||= {}
      end
    end

    def initialize(project, config = {})
      defaults = {}
      
      @config = {}.update(defaults).update(config)
      @project = project
      @stack = []
    end    

    # Use a certain test, this will also register it on the CLI
    #
    # @examples
    #   test.use :jshint, config
    def use(processor, options = {})
      test = self.class.get_callable(processor, Roger::Test.map)

      self.register_in_cli(processor, @stack.length, self.class.cli_map[processor])

      @stack << [test, options]
    end

    def run!
      success = true
      @stack.each do |task|
        ret = call_test(task) # Don't put this on one line, you will fail... :)
        success &&= ret
      end

      success
    end

    def run_test!(index)
      call_test(@stack[index])
    end


    protected

    def call_test(task)
      if (task.kind_of?(Array))
        task[0].call(self, task[1])
      else
        task.call(self)
      end
    end

    def register_in_cli(name, stack_index, klass)
      long_desc = "Run #{name} tests"

      if klass && klass.kind_of?(Class) && klass <= Roger::Test::Cli 
        usage = "#{name} #{klass.arguments.map{ |arg| arg.banner }.join(" ")}"
        thor_class = klass
      else
        usage = "#{name}"
        thor_class = Class.new(Roger::Test::Cli) do
          default_task :test

          class << self
            attr_accessor :stack_index
          end

          desc "test", "run tests"
          def test
            unless Roger::Cli::Base.project.test.run_test!(self.class.stack_index)
              raise Thor::Error, "The test failed"
            end
          end
        end
        thor_class.stack_index = stack_index
      end

      Roger::Cli::Test.register thor_class, name, usage, long_desc

    end
  end
end
