require "thor"
require File.dirname(__FILE__) + "/helpers/get_callable"
require File.dirname(__FILE__) + "/helpers/get_files"
require File.dirname(__FILE__) + "/helpers/logging"

module Roger
  # The test class itself
  class Test
    # The Test CLI Thor command
    class Cli < Thor
      def self.exit_on_failure?
        true
      end

      default_task :test

      class << self
        attr_accessor :stack_index
      end

      desc "test", "Run the test"
      def test
        ok = Roger::Cli::Base.project.test.run_test!(self.class.stack_index)
        fail(Thor::Error, "The test failed") unless ok
      end
    end

    include Roger::Helpers::Logging
    include Roger::Helpers::GetFiles

    attr_reader :config, :project

    class << self
      include Roger::Helpers::GetCallable

      # Register a test method to Roger::Test so it can be used in the Rogerfile

      def register(name, test, cli = nil)
        if map.key?(name)
          fail ArgumentError, "Another test has already claimed the name #{name.inspect}"
        end

        fail ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)
        map[name] = test
        cli_map[name] = cli if cli
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

    # Use a certain test, this will also register it on the CLI if you supply a symbol.
    #
    # @examples
    #   test.use :jshint, config
    def use(processor, options = {})
      test = self.class.get_callable(processor, Roger::Test.map)
      if processor.is_a?(Symbol)
        register_in_cli(processor, @stack.size, self.class.cli_map[processor])
      end
      @stack << [test, options]
    end

    # Run all tests and return true when succeeded
    def run!
      project.mode = :test

      success = true
      @stack.each do |task|
        ret = call_test(task) # Don't put this on one line, you will fail... :)
        success &&= ret
      end

      success
    ensure
      project.mode = nil
    end

    # Run a specific test by stack index.
    def run_test!(index)
      test = @stack[index]
      if test
        call_test(test)
      else
        false
      end
    end

    protected

    def get_files_default_path
      project.path
    end

    def call_test(task)
      if task.is_a?(Array)
        task[0].call(self, task[1])
      else
        task.call(self)
      end
    end

    def register_in_cli(name, stack_index, klass)
      long_desc = "Run #{name} tests"

      if klass && klass.is_a?(Class) && klass <= Roger::Test::Cli
        usage = "#{name} #{klass.arguments.map(&:banner).join(' ')}"
        thor_class = klass
      else
        usage = "#{name}"
        thor_class = Class.new(Roger::Test::Cli)
      end

      if thor_class.respond_to?(:stack_index=)
        thor_class.stack_index = stack_index
      end

      Roger::Cli::Test.register thor_class, name, usage, long_desc
    end
  end
end
