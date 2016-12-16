module Roger
  module Helpers
    # Helper to include the get_callbable method
    module GetCallable
      # Makes callable into a object that responds to call.
      #
      # @param [#call, Symbol, Class] callable If callable already responds to #call will
      #   just return callable, a Symbol will be searched for in the scope parameter, a class
      #   will be instantiated (and checked if it will respond to #call)
      # @param [Hash] map, Mapping to match symbol to a callable
      def get_callable(callable, map)
        return callable if callable.respond_to?(:call)

        callable = map[callable] if callable.is_a?(Symbol) && map.key?(callable)

        callable = callable.new if callable.is_a?(Class)

        if callable.respond_to?(:call)
          callable
        else
          error_message = "Could not resolve #{callable.inspect}. Callable must"
          error_message << "be an object that responds to #call or a symbol that resolve"
          error_message << "to such an object or a class with a #call instance method."
          raise ArgumentError, error_message
        end
      end
    end
  end
end
