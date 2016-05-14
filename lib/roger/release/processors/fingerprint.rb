require "hpricot"
require "digest"
require "fileutils"

require File.dirname(__FILE__) + "../../../resolver"

module Roger::Release::Processors
  # Fingerprint processor
  # This process can be used to fingerprint assets, for caching benefits
  # It does this fingerprinting based on the following approach:
  #  > It expects that urls are ...
  #  > Adds all to a fingerprint blaat ]
  #  > Rewrites the href or src attributes
  #  > At last it writes the assets files to a fingered printed file and
  #  removes the ...
  class Fingerprint < Base
    def initialize(options = {})
      @options = {
        url_attributes: %w(data-fingerprint),
        match: ["**/*.html"],
        skip: []
      }

      @fingerprinted_files = []

      @options.update(options) if options
    end

    def call(release, options = {})
      options = {}.update(@options).update(options)

      log_call(release, options)

      @resolver = Roger::Resolver.new(release.build_path)

      fingerprint_attributes_in_html_files(
        release,
        options[:url_attributes],
        release.get_files(options[:match], options[:skip])
      )

      fingerprint_asset_files!
    end

    protected

    def log_call(release, options)
      log_message = "Fingerprinting all in #{options[:match].inspect} "
      log_message << "files in attributes #{options[:url_attributes].inspect}, "
      log_message << "skipping #{options[:skip].any? ? options[:skip].inspect : 'none'}"
      release.log(self, log_message)
    end

    def fingerprint_attributes_in_html_files(release, attributes, files)
      files.map do |file_path|
        release.log self, "Processing #{file_path}"
        fingerprint_attributes_in_html_file(release, attributes, file_path)
      end
    end

    def fingerprint_attributes_in_html_file(release, attributes, file_path)
      orig_source = File.read(file_path)
      File.open(file_path, "w") do |f|
        f.write(fingerprint_attributes_in_source(release, attributes, file_path, orig_source))
      end
    end

    def fingerprint_attributes_in_source(release, attributes, file_path, source)
      doc = Hpricot(source)
      attributes.each do |attribute|
        (doc / "*[@#{attribute}]").each do |tag|
          link_attr, url = get_url_from_tag(tag)

          asset_file_path = asset_file_path(url, file_path)
          release.debug(self, "Converting '#{tag[link_attr]}' to '#{asset_file_path}'")

          if asset_file_path.nil?
            return release.log(self, "Could not resolve link #{tag[link_attr]} in #{file_path}")
          end

          digest = create_fingerprint_digest(asset_file_path)
          url_with_digest = append_digest(url, digest)

          @fingerprinted_files.push(asset_file_path: asset_file_path,
                                    digest: digest)

          tag[link_attr] = url_with_digest
        end
      end
      doc.to_original_html
    end

    def get_url_from_tag(tag)
      tag_name = tag.name
      case tag_name
      when "link"
        return ["href", tag["href"]]
      when "script"
        return ["src", tag["src"]]
      else
        fail "I don't know how which html attribute to use for url extraction"
      end
    end

    def create_fingerprint_digest(file_path)
      Digest::SHA256.file(file_path).hexdigest
    end

    def append_digest(url, digest)
      ext = Pathname.new(url).extname

      # Remove extension and dot
      url_without_ext = url[0..ext.length * -1 - 1]

      # Add digest and ext back
      url_without_ext + "-" + digest + ext
    end

    # Translate the given path to a fysiek file on file system
    def asset_file_path(url, source_file_path)
      # Absolute url, starting with /
      if url.match(%r{^\/[^\/]})
        absolute_url = url
      else
        # When relative url is given transform this to an absolute path
        # based of the file in which the link is included
        absolute_url = File.join(
          Pathname.new(@resolver.path_to_url source_file_path).dirname,
          url
        )
      end

      @resolver.url_to_path(absolute_url, exact_match: true)
    end

    def fingerprint_asset_files!
      @fingerprinted_files.uniq.each do |file|
        FileUtils.mv file[:asset_file_path],
                     append_digest(file[:asset_file_path].to_s, file[:digest])
      end
    end
  end
end

Roger::Release::Processors.register(:finger, Roger::Release::Processors::Fingerprint)
