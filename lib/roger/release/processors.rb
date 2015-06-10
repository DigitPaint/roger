module Roger::Release::Processors
  class Base
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end

    def call(_release, _options = {})
      fail ArgumentError, "Implement in subclass"
    end
  end

  def self.register(name, processor)
    fail ArgumentError, "Another processor has already claimed the name #{name.inspect}" if map.key?(name)
    fail ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)
    map[name] = processor
  end

  def self.map
    @_map ||= {}
  end
end

require File.dirname(__FILE__) + "/processors/mockup"
require File.dirname(__FILE__) + "/processors/url_relativizer"
