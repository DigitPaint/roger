module Roger
  class Cli::Serve < Cli::Command
    desc "Serve the current project"

    class_options port: :string, # Defaults to 9000
                  host: :string, # Defaults to 0.0.0.0
                  handler: :string # The handler to use (defaults to mongrel)

    def serve
      server_options = {}
      options.each { |k, v| server_options[k.to_sym] = v }
      server_options[:server] = {}
      [:port, :handler, :host].each do |k|
        server_options[:server][k] = server_options.delete(k) if server_options.key?(k)
      end

      server = @project.server
      server.set_options(server_options[:server])

      puts "Running Roger with #{server.handler.inspect} on  #{server.host}:#{server.port}"
      puts project_banner(@project)
    end

    # Hack so we can override it in tests.
    def start
      @project.server.run!
    end
  end
end
