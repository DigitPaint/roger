module RogerSucceedTest
  class Test

    def initialize(options={})
      @options = {}
      @options.update(options) if options            
    end

    def call(test, options={})
      test.log(self, "Going to succeed")
      true
    end

  end
end

Roger::Test.register :succeed, RogerSucceedTest::Test