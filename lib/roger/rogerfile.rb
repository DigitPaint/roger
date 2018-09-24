module Roger
  # Loader for rogerfile
  class Rogerfile
    # This is the context for the rogerfile evaluation. It should be empty except for the
    # #roger method (and deprecated #mockup method).
    class Context
      def initialize(rogerfile)
        @_rogerfile = rogerfile
      end

      def roger
        @_rogerfile
      end

      # @deprecated Please use roger method instead.
      def mockup
        warn("The use of mockup has been deprecated; please use roger instead")
        warn("  on #{caller(0..0).first}")
        roger
      end

      def binding
        ::Kernel.binding
      end
    end

    # @attr :path [Pathname] The path of the rogerfile for this project
    attr_accessor :path, :project

    def initialize(project, path = nil)
      @project = project
      @path = (path && Pathname.new(path)) || Pathname.new(project.path + "Rogerfile")
    end

    # Actually load the rogerfile
    def load
      return unless File.exist?(@path) && !loaded?

      @source = File.read(@path)
      context = Context.new(self)
      eval @source, context.binding, @path.to_s, 1 # rubocop:disable Lint/Eval
      @loaded = true
    end

    # Wether or not the rogerfile has been loaded
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

    alias server serve

    def test(options = {})
      test = project.test(options)
      yield(test) if block_given?
      test
    end
  end
end
