require "fileutils"

module Roger::Release::Finalizers
  # Finalizes the release into a directory in target_path
  #
  # The directory name will have the format PREFIX-VERSION
  #
  class Dir < Base
    # @option options :prefix Prefix to put before the version (default = "html")
    def call(release, options = {})
      options = {}.update(@options)
      options.update(options) if options

      name = [(options[:prefix] || "html"), release.scm.version].join("-")
      target_path = release.target_path + name

      release.log(self, "Finalizing release to #{target_path}")

      if File.exist?(target_path)
        release.log(self, "Removing existing target #{target_path}")
        FileUtils.rm_rf(target_path)
      end

      FileUtils.cp_r release.build_path, target_path
    end
  end
end

Roger::Release::Finalizers.register(:dir, Roger::Release::Finalizers::Dir)
