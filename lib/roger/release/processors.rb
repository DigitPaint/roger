module Roger::Release::Processors
  class Base
    
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end
  
    
    def call(release, options = {})
      raise ArgumentError, "Implement in subclass"
    end
  end

  def self.register(name, processor)
    raise ArgumentError, "Another processor has already claimed the name #{name.inspect}" if self.map.has_key?(name)
    raise ArgumentError, "Name must be a symbol" unless name.kind_of?(Symbol)
    self.map[name] = processor
  end

  def self.map
    @_map ||= {}
  end

end

require File.dirname(__FILE__) + "/processors/mockup"
require File.dirname(__FILE__) + "/processors/url_relativizer"
