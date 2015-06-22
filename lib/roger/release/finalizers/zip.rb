module Roger::Release::Finalizers
  # The zip finalizer
  # The zip finalizer will
  class Zip < Base
    attr_reader :release

    # @option options :prefix Prefix to put before the version (default = "html")
    # @option options :zip The zip command
    def call(release, options = {})
      options = {
        zip: "zip",
        prefix: "html"
      }.update(@options)

      options.update(options) if options

      name = [options[:prefix], release.scm.version].join("-") + ".zip"
      zip_path = release.target_path + name

      release.log(self, "Finalizing release to #{zip_path}")

      cleanup_existing_zip(release, zip_path)

      check_zip_command(options[:zip])

      ::Dir.chdir(release.build_path) do
        `#{options[:zip]} -r -9 "#{zip_path}" ./*`
      end
    end

    protected

    def cleanup_existing_zip(release, path)
      return unless File.exist?(path)

      release.log(self, "Removing existing target #{path}")
      FileUtils.rm_rf(path)
    end

    def check_zip_command(command)
      `#{command} -v`
    rescue Errno::ENOENT
      raise "Could not find zip in #{command.inspect}"
    end
  end
end
Roger::Release::Finalizers.register(:zip, Roger::Release::Finalizers::Zip)
