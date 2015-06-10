module RogerNoopTest
  # Noop test. Doesn't do anything except log a normal line and log a debug line
  # Will always pass
  class Test
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end

    def call(test, _options = {})
      test.log(self, "NOOP")
      test.debug(self, "NOOP DEBUG")
      true
    end
  end
end
