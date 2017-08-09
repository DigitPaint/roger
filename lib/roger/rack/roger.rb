require "rack/request"
require "rack/response"
require "rack/file"

require File.dirname(__FILE__) + "/../resolver"
require File.dirname(__FILE__) + "/../renderer"

module Roger
  module Rack
    # Roger middleware that processe roger templates
    class Roger
      include ::Roger::Helpers::GetFiles
      attr_reader :project

      def default_options
        {
          match: ["**/*.{html,md,html.erb}"],
          skip: []
        }
      end

      # Initialize the Rack app
      #
      # @param [Hash] options Options to use
      #
      # @option options
      def initialize(project, options = {})
        @project = project
        @options = default_options.update(options)
        @docroot = project.html_path

        @resolver = Resolver.new(@docroot)
        @file_server = ::Rack::File.new(@docroot)
      end

      def call(env)
        url = env["PATH_INFO"]
        env["MOCKUP_PROJECT"] = env["roger.project"] || @project

        template_path = @resolver.url_to_path(url)
        if process_path_by_roger?(template_path)
          env["rack.errors"].puts "Rendering template #{template_path.inspect} (#{url.inspect})"
          build_response(template_path, env).finish
        else
          env["rack.errors"].puts "Invoking file handler for #{url.inspect}"
          @file_server.call(env)
        end
      end

      protected

      # Wether or not we should process this
      # path by the Roger renderer.
      def process_path_by_roger?(path)
        return false unless path

        return false unless match_path(path, @options[:match], @options[:skip])

        ::Roger::Renderer.will_render?(path)
      end

      def build_response(template_path, env)
        renderer = ::Roger::Renderer.new(
          env,
          partials_path: @project.partials_path,
          layouts_path: @project.layouts_path
        )
        mime = ::Rack::Mime.mime_type(File.extname(template_path), "text/html")
        ::Rack::Response.new do |res|
          res.headers["Content-Type"] = mime if mime
          res.headers["X-Handled-By"] = "Roger"
          res.status = 200
          res.write renderer.render(template_path, @project.options[:renderer] || {})
        end
      end
    end
  end
end
