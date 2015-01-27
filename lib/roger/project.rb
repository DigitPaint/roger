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
    attr_accessor :path, :html_path, :partial_path, :layouts_path, :mockupfile, :mockupfile_path

    attr_accessor :shell

    attr_accessor :options

    def initialize(path, options={})
      @path = Pathname.new(path)

      @options = {
        :html_path => @path + "html",
        :partial_path => @path + "partials",
        :layouts_path => @path + "layouts",
        :mockupfile_path => @path + "Mockupfile"
      }

      # Clumsy string to symbol key conversion
      options.each{|k,v| @options[k.is_a?(String) ? k.to_sym : k] = v }

      self.html_path = @options[:html_path]
      self.partial_path = @options[:partials_path] || @options[:partial_path] || self.html_path + "../partials/"
      self.layouts_path = @options[:layouts_path]
      self.mockupfile_path = @options[:mockupfile_path]
      self.shell = @options[:shell]

      if self.mockupfile_path
        @mockupfile = Mockupfile.new(self, self.mockupfile_path)
        @mockupfile.load
      else
        @mockupfile = Mockupfile.new(self)
      end

    end

    def shell
      @shell ||= Thor::Base.shell.new
    end

    def server
      options = @options[:server] || {}
      @server ||= Server.new(self, options)
    end

    def release
      options = @options[:release] || {}
      @release ||= Release.new(self, options)
    end

    def test
      options = @options[:test] || {}
      @test ||= Test.new(self, options)
    end

    def html_path=(p)
      @html_path = self.realpath_or_path(p)
    end

    def partial_path=(p)
      @partial_path = self.single_or_multiple_paths(p)
    end
    alias :partials_path :partial_path
    alias :partials_path= :partial_path=

    def layouts_path=(p)
      @layouts_path = self.single_or_multiple_paths(p)
    end

    protected

    def single_or_multiple_paths(p)
      if p.kind_of?(Array)
        p.map{|tp| self.realpath_or_path(tp) }
      else
        self.realpath_or_path(p)
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
