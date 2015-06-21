require File.dirname(__FILE__) + "../../../resolver"

module Roger::Release::Processors
  # URL relativizer processor
  # The relativizer can be used to rewrite absolute paths in attributes to relative paths
  # during release.
  class UrlRelativizer < Base
    def initialize(options = {})
      @options = {
        url_attributes: %w(src href action),
        match: ["**/*.html"],
        skip: []
      }

      @options.update(options) if options
    end

    def call(release, options = {})
      options = {}.update(@options).update(options)

      log_call(release, options)

      @resolver = Roger::Resolver.new(release.build_path)

      relativize_attributes_in_files(
        release,
        options[:url_attributes],
        release.get_files(options[:match], options[:skip])
      )
    end

    protected

    def log_call(release, options)
      log_message = "Relativizing all URLS in #{options[:match].inspect}"
      log_message << "files in attributes #{options[:url_attributes].inspect},"
      log_message << "skipping #{options[:skip].any? ? options[:skip].inspect : 'none' }"
      release.log(self, log_message)
    end

    def relativize_attributes_in_files(release, attributes, files)
      files.each do |file_path|
        release.debug(self, "Relativizing URLS in #{file_path}") do
          relativize_attributes_in_file(release, attributes, file_path)
        end
      end
    end

    def relativize_attributes_in_file(release, attributes, file_path)
      orig_source = File.read(file_path)
      File.open(file_path, "w") do |f|
        f.write(relativize_attributes_in_source(release, attributes, orig_source, file_path))
      end
    end

    def relativize_attributes_in_source(release, attributes, source, file_path)
      doc = Hpricot(source)
      attributes.each do |attribute|
        (doc / "*[@#{attribute}]").each do |tag|
          converted_url = @resolver.url_to_relative_url(tag[attribute], file_path)
          release.debug(self, "Converting '#{tag[attribute]}' to '#{converted_url}'")
          case converted_url
          when String
            tag[attribute] = converted_url
          when nil
            release.log(self, "Could not resolve link #{tag[attribute]} in #{file_path}")
          end
        end
      end
      doc.to_original_html
    end
  end
end

Roger::Release::Processors.register(:url_relativizer, Roger::Release::Processors::UrlRelativizer)
