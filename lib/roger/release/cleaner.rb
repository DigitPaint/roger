module Roger
  # The cleaner safely cleans up paths
  class Release::Cleaner
    def initialize(pattern)
      @pattern = [pattern].flatten
    end

    # We switch to the build path and append the globbed files for safety, so even if you manage
    # to sneak in a pattern like "/**/*" it won't do you any good as it will be reappended
    # to the path
    def call(release, _options = {})
      Dir.chdir(release.build_path.to_s) do
        @pattern.each do |pattern|
          Dir.glob(pattern).each do |file|
            clean_path(release, file)
          end
        end
      end
    end

    def clean_path(release, file)
      path = File.join(release.build_path.to_s, file)
      if inside_build_path?(release.build_path, path)
        release.log(self, "Cleaning up \"#{path}\" in build")
        rm_rf(path)
        true
      else
        release.log(self, "FAILED cleaning up \"#{path}\" in build")
        false
      end
    end

    protected

    def inside_build_path?(build_path, path)
      begin
        build_path = Pathname.new(build_path).realpath.to_s
        path = Pathname.new(path)
        path = if path.absolute?
                 path.realpath.to_s
               else
                 Pathname.new(File.join(build_path.to_s, path)).realpath.to_s
               end
      rescue Errno::ENOENT
        # Real path does not exist
        return false
      end

      raise "Cleaning pattern is not inside build directory" unless path[build_path]

      true
    end
  end
end
