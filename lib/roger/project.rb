require File.dirname(__FILE__) + "/release"
require File.dirname(__FILE__) + "/server"
require File.dirname(__FILE__) + "/test"

require File.dirname(__FILE__) + "/rogerfile"

module Roger
  # Loader for rogerfile and project dependencies
  class Project
    # @attr :path [Pathname] The project path
    # @attr :html_path [Pathname] The path of the HTML of this project
    # @attr :partial_path [Pathname] The path for the partials for this project
    # @attr :rogerfile [Rogerfile] The Rogerfile for this project
    # @attr :rogerfile_path [Pathname] The path to the Rogerfile
    # @attr :mode [nil, :test, :server, :release] The mode we're currently in.
    #   If nil, we aren't doing anything.
    attr_accessor :path, :html_path, :partial_path, :layouts_path,
                  :rogerfile, :rogerfile_path, :mode

    attr_accessor :shell

    attr_accessor :options

    def initialize(path, options = {})
      @path = Pathname.new(path)

      @options = {
        html_path: @path + "html",
        partial_path: @path + "partials",
        layouts_path: @path + "layouts",
        rogerfile_path: @path + "Rogerfile",
        renderer: {},
        server: {},
        release: {},
        test: {}
      }

      # Clumsy string to symbol key conversion
      options.each { |k, v| @options[k.is_a?(String) ? k.to_sym : k] = v }

      initialize_accessors
      initialize_rogerfile_path
      initialize_roger
    end

    def shell
      @shell ||= Thor::Base.shell.new
    end

    def server(options = {})
      @server ||= Server.new(self, merge_options(options, :server))
    end

    def release(options = {})
      @release ||= Release.new(self, merge_options(options, :release))
    end

    def test(options = {})
      @test ||= Test.new(self, merge_options(options, :test))
    end

    def html_path=(p)
      @html_path = realpath_or_path(p)
    end

    def partial_path=(p)
      @partial_path = single_or_multiple_paths(p)
    end
    alias partials_path partial_path
    alias partials_path= partial_path=

    def layouts_path=(p)
      @layouts_path = single_or_multiple_paths(p)
    end

    protected

    # Creates new options and merges:
    # - @options[:key]
    # - passed options
    #
    def merge_options(options, key)
      {}.update(@options[key]).update(options)
    end

    def initialize_rogerfile_path
      # We stop immediately if rogerfile is not a Pathname
      unless @options[:rogerfile_path].is_a? Pathname
        self.rogerfile_path = @options[:rogerfile_path]
        return
      end

      # If roger file exist we're good to go
      if @options[:rogerfile_path].exist?
        self.rogerfile_path = @options[:rogerfile_path]
      else
        # If the rogerfile does not exist we check for deprecated Mockupfile
        mockupfile_path = path + "Mockupfile"
        if mockupfile_path.exist?
          warn("Mockupfile has been deprecated! Please rename Mockupfile to Rogerfile")
          self.rogerfile_path = mockupfile_path
        end
      end
    end

    def initialize_accessors
      self.html_path = @options[:html_path]
      self.partial_path =
        @options[:partials_path] || @options[:partial_path] || html_path + "../partials/"
      self.layouts_path = @options[:layouts_path]
      self.shell = @options[:shell]
    end

    def initialize_roger
      if rogerfile_path
        @rogerfile = Rogerfile.new(self, rogerfile_path)
        @rogerfile.load
      else
        @rogerfile = Rogerfile.new(self)
      end
    end

    def single_or_multiple_paths(p)
      if p.is_a?(Array)
        p.map { |tp| realpath_or_path(tp) }
      else
        realpath_or_path(p)
      end
    end

    def realpath_or_path(path)
      path = Pathname.new(path)
      if path.exist?
        path.realpath
      else
        path
      end
    end
  end
end
