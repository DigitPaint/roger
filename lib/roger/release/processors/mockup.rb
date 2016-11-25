require File.dirname(__FILE__) + "/../../renderer"

module Roger::Release::Processors
  # The Mockup processor that will process all templates
  class Mockup < Base
    self.name = :mockup

    MIME_TYPES_TO_EXTENSION = {
      "text/html" => "html",
      "text/css"  => "css",
      "application/javascript" => "js",
      "text/xml" => "xml",
      "application/xml" => "xml",
      "text/csv" => "csv",
      "application/json" => "json"
    }

    def default_options
      {
        env: {},
        match: ["**/*.{html,md,html.erb}"],
        skip: [/\Astylesheets/, /\Ajavascripts/]
      }
    end

    def project
      release.project
    end

    def perform
      @options[:env].update("roger.project" => project, "MOCKUP_PROJECT" => project)

      log_call

      release.get_files(@options[:match], @options[:skip]).each do |file_path|
        release.log(self, "    Extract: #{file_path}", true)

        # Avoid rendering partials which can also be included
        # in the roger.base_path
        next if File.basename(file_path).start_with? "_"

        run_on_file!(file_path, @options[:env])
      end
    end

    def run_on_file!(file_path, env = {})
      output = run_on_file(file_path, env)

      # Clean up source file
      FileUtils.rm(file_path)

      # Write out new file
      File.open(target_path(file_path).to_s, "w") do |f|
        f.write(output)
      end
    end

    # Runs the template on a single file and return processed source.
    def run_on_file(file_path, env = {})
      renderer = Roger::Renderer.new(
        env.dup,
        partials_path: project.partial_path,
        layouts_path: project.layouts_path
      )
      renderer.render(file_path, project.options[:renderer] || {})
    end

    # Determines the output path for a mockup path with a certain template
    #
    # @return [Pathname]
    def target_path(path)
      parts = File.basename(path.to_s).split(".")
      path = path.to_s

      # Always return .html directly as it will cause too much trouble otherwise
      return Pathname.new(path) if parts.last == "html"

      target_ext = Roger::Renderer.target_extension_for(path)
      source_ext = Roger::Renderer.source_extension_for(path)

      # If there is no target extension
      return Pathname.new(path) if target_ext.empty?

      # If we have at least one extension
      if parts.size > 1
        source_ext_regexp = /#{Regexp.escape(source_ext)}\Z/
        Pathname.new(path.gsub(source_ext_regexp, target_ext))
      else
        Pathname.new(path + "." + target_ext)
      end
    end

    protected

    def log_call
      release.log(self, "Processing mockup files")

      release.log(self, "  Matching: #{@options[:match].inspect}", true)
      release.log(self, "  Skiping : #{@options[:skip].inspect}", true)
      release.log(self, "  Env     : #{@options[:env].inspect}", true)
      release.log(self, "  Files   :", true)
    end
  end
end
Roger::Release::Processors.register(Roger::Release::Processors::Mockup)
