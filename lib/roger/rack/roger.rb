require "rack/request"
require "rack/response"
require "rack/file"

require File.dirname(__FILE__) + "/../resolver"

module Roger
  module Rack
    # Roger middleware that processe roger templates
    class Roger
      attr_reader :project

      def initialize(project)
        @project = project
        @docroot = project.html_path

        @resolver = Resolver.new(@docroot)
        @file_server = ::Rack::File.new(@docroot)
      end

      def call(env)
        url = env["PATH_INFO"]
        env["MOCKUP_PROJECT"] = project

        if template_path = @resolver.url_to_path(url)
          env["rack.errors"].puts "Rendering template #{template_path.inspect} (#{url.inspect})"
          build_response(template_path).finish
        else
          env["rack.errors"].puts "Invoking file handler for #{url.inspect}"
          @file_server.call(env)
        end
      end

      protected

      def build_response(template_path)
        templ = ::Roger::Template.open(
          template_path,
          partials_path: @project.partials_path,
          layouts_path: @project.layouts_path
        )
        mime = ::Rack::Mime.mime_type(File.extname(template_path), "text/html")
        ::Rack::Response.new do |res|
          res.headers["Content-Type"] = mime if mime
          res.status = 200
          res.write templ.render(env)
        end
      end
    end
  end
end
