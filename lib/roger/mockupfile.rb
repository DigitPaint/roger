module Roger
  # Loader for mockupfile
  class Mockupfile
    # This is the context for the mockupfile evaluation. It should be empty except for the
    # #mockup method.
    class Context
      def initialize(mockupfile)
        @_mockupfile = mockupfile
      end

      def mockup
        @_mockupfile
      end

      def binding
        ::Kernel.binding
      end
    end

    # @attr :path [Pathname] The path of the Mockupfile for this project
    attr_accessor :path, :project

    def initialize(project, path = nil)
      @project = project
      @path = (path && Pathname.new(path)) || Pathname.new(project.path + "Mockupfile")
    end

    # Actually load the mockupfile
    def load
      return unless File.exist?(@path) && !self.loaded?

      @source = File.read(@path)
      context = Context.new(self)
      eval @source, context.binding, @path.to_s, 1 # rubocop:disable Lint/Eval
      @loaded = true
    end

    # Wether or not the Mockupfile has been loaded
    def loaded?
      @loaded
    end

    def release(options = {})
      release = project.release(options)
      yield(release) if block_given?
      release
    end

    def serve(options = {})
      server = project.server(options)
      yield(server) if block_given?
      server
    end

    alias_method :server, :serve

    def test(options = {})
      test = project.test(options)
      yield(test) if block_given?
      test
    end
  end
end
