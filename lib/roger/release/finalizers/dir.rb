require "fileutils"

module Roger::Release::Finalizers
  # Finalizes the release into a directory in target_path
  #
  # The directory name will have the format PREFIX-VERSION
  #
  class Dir < Base
    self.name = :dir

    # @option options :prefix Prefix to put before the version (default = "html")
    def default_options
      {
        prefix: "html",
        target_path: release.target_path
      }
    end

    def perform
      name = [@options[:prefix], @release.scm.version].join("-")

      target_dir = Pathname.new(@options[:target_path])
      FileUtils.mkdir_p(target_dir) unless target_dir.exist?

      target_path = target_dir + name

      release.log(self, "Finalizing release to #{target_path}")

      if File.exist?(target_path)
        release.log(self, "Removing existing target #{target_path}")
        FileUtils.rm_rf(target_path)
      end

      FileUtils.cp_r release.build_path, target_path
    end
  end
end

Roger::Release::Finalizers.register(Roger::Release::Finalizers::Dir)
