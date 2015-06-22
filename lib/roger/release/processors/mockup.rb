module Roger::Release::Processors
  # The Mockup processor that will process all templates
  class Mockup < Base
    attr_accessor :project

    MIME_TYPES_TO_EXTENSION = {
      "text/html" => "html",
      "text/css"  => "css",
      "application/javascript" => "js",
      "text/xml" => "xml",
      "application/xml" => "xml",
      "text/csv" => "csv",
      "application/json" => "json"
    }

    def initialize(options = {})
      @options = {
        env: {},
        match: ["**/*.{html,md,html.erb}"],
        skip: [/\Astylesheets/, /\Ajavascripts/]
      }

      @options.update(options) if options
    end

    def call(release, options = {})
      self.project = release.project

      options = update_call_options(options)

      log_call(release, options)

      release.get_files(options[:match], options[:skip]).each do |file_path|
        release.log(self, "    Extract: #{file_path}", true)
        self.run_on_file!(file_path, options[:env])
      end
    end

    def run_on_file!(file_path, env = {})
      template = Roger::Template.open(
        file_path,
        partials_path: project.partial_path,
        layouts_path: project.layouts_path
      )

      # Clean up source file
      FileUtils.rm(file_path)

      # Write out new file
      File.open(target_path(file_path, template).to_s, "w") do |f|
        f.write(template.render(env.dup))
      end
    end

    # Runs the extractor on a single file and return processed source.
    def extract_source_from_file(file_path, env = {})
      Roger::Template.open(
        file_path,
        partials_path: project.partial_path,
        layouts_path: project.layouts_path
      ).render(env.dup)
    end

    # Determines the output path for a mockup path with a certain template
    #
    # @return [Pathname]
    def target_path(path, template)
      parts, dir = split_path(path)

      # Always return .html directly as it will cause too much trouble otherwise
      return Pathname.new(path) if parts.last == "html"

      # Strip last extension if we have a double extension
      return dir + parts[0..-2].join(".") if parts.size > 2

      dir + extension_based_on_mime_type(parts, template.template.class.default_mime_type)
    end

    protected

    def update_call_options(options)
      updated_options = {}
      updated_options.update(@options)

      updated_options.update(options) if options

      updated_options[:env].update("roger.project" => project, "MOCKUP_PROJECT" => project)

      updated_options
    end

    def log_call(release, options)
      release.log(self, "Processing mockup files")

      release.log(self, "  Matching: #{options[:match].inspect}", true)
      release.log(self, "  Skiping : #{options[:skip].inspect}", true)
      release.log(self, "  Env     : #{options[:env].inspect}", true)
      release.log(self, "  Files   :", true)
    end

    # Split the path into two parts:
    # 1. Filename, in an array, split by .
    # 2. Pathname of directory
    def split_path(path)
      [
        File.basename(path.to_s).split("."),
        Pathname.new(File.dirname(path.to_s))
      ]
    end

    def extension_based_on_mime_type(parts, mime_type)
      # 2. Try to figure out the extension based on the template's mime-type
      extension = MIME_TYPES_TO_EXTENSION[mime_type]

      # No matching extension, let's return path
      return parts.join(".") if extension.nil?

      if parts.size > 1
        # Strip extension and replace with extension
        (parts[0..-2] << extension).join(".")
      else
        # Let's just add the extension
        (parts << extension).join(".")
      end
    end
  end
end
Roger::Release::Processors.register(:mockup, Roger::Release::Processors::Mockup)
