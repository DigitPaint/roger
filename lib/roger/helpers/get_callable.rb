module Roger
  module Helpers
    module GetCallable
      # Makes callable into a object that responds to call. 
      #
      # @param [#call, Symbol, Class] callable If callable already responds to #call will just return callable, a Symbol will be searched for in the scope parameter, a class will be instantiated (and checked if it will respond to #call)
      # @param [Hash] map, Mapping to match symbol to a callable
      def get_callable(callable, map)
        return callable if callable.respond_to?(:call)
      
        if callable.kind_of?(Symbol) && map.has_key?(callable)
          callable = map[callable]
        end
      
        if callable.kind_of?(Class)
          callable = callable.new
        end
      
        if callable.respond_to?(:call)
          callable
        else
          raise ArgumentError, "Could not resolve #{callable.inspect}. Callable must be an object that responds to #call or a symbol that resolve to such an object or a class with a #call instance method."
        end
      
      end
    end
  end
end