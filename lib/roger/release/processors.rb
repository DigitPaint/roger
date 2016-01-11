module Roger
  class Release
    # The Processors namespace
    module Processors
      # Abstract Processor class
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
        fail ArgumentError, "Processor name '#{name.inspect}' already in use" if map.key?(name)
        fail ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)
        map[name] = processor
      end

      def self.map
        @_map ||= {}
      end
    end
  end
end

require File.dirname(__FILE__) + "/processors/fingerprint"
require File.dirname(__FILE__) + "/processors/mockup"
require File.dirname(__FILE__) + "/processors/url_relativizer"
