require File.dirname(__FILE__) + "/release"
require File.dirname(__FILE__) + "/server"
require File.dirname(__FILE__) + "/test"

require File.dirname(__FILE__) + "/mockupfile"

module Roger
  # Loader for mockupfile and project dependencies
  class Project
    # @attr :path [Pathname] The project path
    # @attr :html_path [Pathname] The path of the HTML mockup
    # @attr :partial_path [Pathname] The path for the partials for this mockup
    # @attr :mockupfile [Mockupfile] The Mockupfile for this project
    # @attr :mockupfile_path [Pathname] The path to the Mockupfile
    # @attr :mode [nil, :test, :server, :release] The mode we're currently in.
    #   If nil, we aren't doing anything.
    attr_accessor :path, :html_path, :partial_path, :layouts_path,
                  :mockupfile, :mockupfile_path, :mode

    attr_accessor :shell

    attr_accessor :options

    def initialize(path, options = {})
      @path = Pathname.new(path)

      @options = {
        html_path: @path + "html",
        partial_path: @path + "partials",
        layouts_path: @path + "layouts",
        mockupfile_path: @path + "Mockupfile",
        server: {},
        release: {},
        test: {}
      }

      # Clumsy string to symbol key conversion
      options.each { |k, v| @options[k.is_a?(String) ? k.to_sym : k] = v }

      initialize_accessors
      initialize_mockup
    end

    def shell
      @shell ||= Thor::Base.shell.new
    end

    def server(options = {})
      options = {}.update(@options[:server]).update(options)
      @server ||= Server.new(self, options)
    end

    def release(options = {})
      options = {}.update(@options[:release]).update(options)
      @release ||= Release.new(self, options)
    end

    def test(options = {})
      options = {}.update(@options[:test]).update(options)
      @test ||= Test.new(self, options)
    end

    def html_path=(p)
      @html_path = realpath_or_path(p)
    end

    def partial_path=(p)
      @partial_path = single_or_multiple_paths(p)
    end
    alias_method :partials_path, :partial_path
    alias_method :partials_path=, :partial_path=

    def layouts_path=(p)
      @layouts_path = single_or_multiple_paths(p)
    end

    protected

    def initialize_accessors
      self.html_path = @options[:html_path]
      self.partial_path =
        @options[:partials_path] || @options[:partial_path] || html_path + "../partials/"
      self.layouts_path = @options[:layouts_path]
      self.mockupfile_path = @options[:mockupfile_path]
      self.shell = @options[:shell]
    end

    def initialize_mockup
      if mockupfile_path
        @mockupfile = Mockupfile.new(self, mockupfile_path)
        @mockupfile.load
      else
        @mockupfile = Mockupfile.new(self)
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
