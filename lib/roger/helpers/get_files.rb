module Roger
  module Helpers
    # Helper to include the get_files method
    module GetFiles
      GLOB_OPTIONS = File::FNM_PATHNAME | File::FNM_EXTGLOB | File::FNM_DOTMATCH

      # Get files from a path, skipping excludes.
      #
      # @param [Array] globs an array of file path globs that will be globbed
      #                against the project path
      # @param [Array] excludes an array of regexps[!] that will be excluded
      #                from the result.
      def get_files(globs, excludes = [])
        path = Pathname.new(get_files_default_path)
        files = globs.map { |g| Dir.glob(path + g, GLOB_OPTIONS) }.flatten
        files.reject! { |file| excludes.detect { |e| file.match(e) } } if excludes.any?
        files.select { |file| File.file?(file) }
      end

      # See if a file matches globs/excludes
      #
      # @param [.to_s] path the path to match
      # @param [Array] globs an array of file path globs that will be matched against path
      # @param [Array] exclude an array of regexps[!] that will be matched negatively against path
      #
      # @return [Boolean] Did the passed path match against the globs and excludes?
      def match_path(path, globs, excludes = [])
        path = path.to_s
        match = globs.detect { |glob| File.fnmatch?(glob, path, GLOB_OPTIONS) }
        return false unless match # No need to check excludes if we don't match anyway

        !excludes.find { |e| path.match(e) }
      end

      protected

      # The default path to use when calling get_files
      def get_files_default_path
        raise "Implement #get_files_default_path in your class"
      end
    end
  end
end
