module Roger
  # The serve command
  class Cli::Serve < Cli::Command
    desc "Serve the current project"

    class_options port: :string, # Defaults to 9000
                  host: :string, # Defaults to 0.0.0.0
                  handler: :string # The handler to use

    def serve
      server_options = {}
      options.each { |k, v| server_options[k.to_sym] = v }
      server_options[:server] = {}
      [:port, :handler, :host].each do |k|
        server_options[:server][k] = server_options.delete(k) if server_options.key?(k)
      end

      @project.server.set_options(server_options[:server])
    end

    def start
      server = @project.server

      @project.server.run! do |server_instance|
        puts "Running Roger with #{server.used_handler.inspect}"
        puts "  Host: #{server.host}"
        puts "  Port: #{server.used_port}"
        puts
        puts project_banner(@project)

        # Hack so we can override it in tests.
        yield server_instance if block_given?
      end
    end
  end
end
