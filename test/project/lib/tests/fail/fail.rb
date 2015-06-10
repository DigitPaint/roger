module RogerFailTest
  class Test
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end

    def call(test, _options = {})
      test.log(self, "Going to fail")
      false
    end
  end
end

Roger::Test.register :fail, RogerFailTest::Test
