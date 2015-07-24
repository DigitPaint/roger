require "rack"
require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/rack/roger"

require "webrick"
require "webrick/https"

module Roger
  # The Roger webserver. Initializes a rack server.
  class Server
    attr_reader :server_options

    attr_reader :project

    attr_accessor :port, :handler, :host

    def initialize(project, options = {})
      @project = project

      @stack = initialize_rack_builder

      @server_options = {}

      # Defaults
      self.port = 9000
      self.handler = nil
      self.host = "0.0.0.0"

      set_options(options)
    end

    # Sets the options, this is a separate method as we want to override certain
    # things set in the rogerfile from the commandline
    def set_options(options)
      self.port = options[:port] if options.key?(:port)
      self.handler = options[:handler] if options.key?(:handler)
      self.host = options[:host] if options.key?(:host)
    end

    # Use the specified Rack middleware
    #
    # @see ::Rack::Builder#use
    def use(*args, &block)
      @stack.use(*args, &block)
    end

    # Use the map handler to map endpoints to certain urls
    #
    # @see ::Rack::Builder#map
    def map(*args, &block)
      @stack.map(*args, &block)
    end

    def run!
      project.mode = :server
      handler.run application, server_options do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "Roger, out!"
        end
      end
    ensure
      project.mode = nil
    end
    alias_method :run, :run!

    def port=(p)
      @port = server_options[:Port] = p
    end

    def host=(h)
      @host = server_options[:Host] = h
    end

    def handler=(h)
      if h.respond_to?(:run)
        @handler = h
      else
        @handler = get_handler(h)
      end
    end

    protected

    # Build the final application that get's run by the Rack Handler
    def application
      return @app if @app

      @stack.run Rack::Roger.new(project)

      @app = @stack
    end

    # Initialize the Rack builder instance for this server
    #
    # @return ::Rack::Builder instance
    def initialize_rack_builder
      roger_env = Class.new do
        class << self
          attr_accessor :project
        end

        def initialize(app)
          @app = app
        end

        def call(env)
          env["roger.project"] = self.class.project
          @app.call(env)
        end
      end

      roger_env.project = project

      builder = ::Rack::Builder.new
      builder.use roger_env
      builder.use ::Rack::ShowExceptions
      builder.use ::Rack::Lint
      builder.use ::Rack::ConditionalGet
      builder.use ::Rack::Head

      builder
    end

    # Get the actual handler for use in the server
    # Will always return a handler, it will try to use the fallbacks
    def get_handler(preferred_handler_name = nil)
      servers = %w(puma mongrel thin webrick)
      servers.unshift(preferred_handler_name) if preferred_handler_name

      handler, server_name = detect_valid_handler(servers)

      if preferred_handler_name && server_name != preferred_handler_name
        puts "Handler '#{preferred_handler_name}' not found, using fallback ('#{handler.inspect}')."
      end
      handler
    end

    # See what handlers work
    def detect_valid_handler(servers)
      handler = nil
      while (server_name = servers.shift) && handler.nil?
        begin
          handler = ::Rack::Handler.get(server_name)
          return [handler, server_name]
        rescue LoadError
          handler = nil
        rescue NameError
          handler = nil
        end
      end
    end
  end
end
