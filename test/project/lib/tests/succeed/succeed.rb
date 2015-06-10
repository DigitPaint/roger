module RogerSucceedTest
  # A simple Roger test that will succeed
  class Test
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end

    def call(test, _options = {})
      test.log(self, "Going to succeed")
      true
    end
  end
end

Roger::Test.register :succeed, RogerSucceedTest::Test
