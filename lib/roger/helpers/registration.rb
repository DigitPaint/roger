module Roger
  module Helpers
    # Helper module to handle registration
    module Registration
      # Register a class with a name. The method can have the following signatures:
      #
      # def register(processor)
      #
      # and for legacy reasons:
      #
      # def register(name, processor)
      #
      # in the first case the processor must have a name class method.
      def register(name, processor = nil)
        if name.is_a?(Class)
          processor = name
          name = processor.name
        end

        type = to_s.split("::").last

        fail ArgumentError, "#{type} name '#{name.inspect}' already in use" if map.key?(name)
        fail ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)

        map[name] = processor
      end

      def map
        @_map ||= {}
      end
    end
  end
end
