module Roger
  module Helpers
    # Helper to include the get_files method
    module GetFiles
      # Get files from a path, skipping excludes.
      #
      # @param [Array] globs an array of file path globs that will be globbed
      #                against the project path
      # @param [Array] excludes an array of regexps[!] that will be excluded
      #                from the result.
      # @param [String, Pathname] Path to search files in
      def get_files(globs, excludes = [], path = nil)
        path = Pathname.new(get_files_default_path)
        files = globs.map { |g| Dir.glob(path + g) }.flatten
        files.reject! { |file| excludes.detect { |e| file.match(e) } } if excludes.any?
        files.select { |file| File.file?(file) }
      end

      protected

      # The default path to use when calling get_files
      def get_files_default_path
        fail "Implement #get_files_default_path in your class"
      end
    end
  end
end
