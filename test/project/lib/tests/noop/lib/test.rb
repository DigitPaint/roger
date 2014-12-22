module RogerNoopTest
  class Test

    def initialize(options={})
      @options = {}
      @options.update(options) if options            
    end

    def call(test, options={})
      puts "Nooping"
      true
    end

  end
end