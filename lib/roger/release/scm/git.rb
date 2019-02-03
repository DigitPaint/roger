require "pathname"
require "English"

module Roger
  class Release
    module Scm
      # The GIT SCM implementation for Roger release
      class Git < Base
        # Find the .git dir in path and all it's parents
        def self.find_git_dir(path)
          path = Pathname.new(path).realpath
          while path.parent != path && !(path + ".git").directory?
            path = path.parent
          end

          path += ".git"

          raise "Could not find suitable .git dir in #{path}" unless path.directory?

          path
        end

        # @option config [String] :ref Ref to use for current tag
        # @option config [String, Pathname] :path Path to working dir
        def initialize(config = {})
          super(config)
          @config[:ref] ||= "HEAD"
        end

        # Version is either:
        # - the tagged version number (first "v" will be stripped) or
        # - the return value of "git describe --tags HEAD"
        # - the short SHA1 if there hasn't been a previous tag
        def version
          get_scm_data if @_version.nil?
          @_version
        end

        # Date will be Time.now if it can't be determined from GIT repository
        def date
          get_scm_data if @_date.nil?
          @_date
        end

        def previous
          self.class.new(@config.dup.update(ref: get_previous_tag_name))
        end

        protected

        def get_previous_tag_name
          # Get list of SHA1 that have a ref
          sha1s = `git --git-dir=#{safe_git_dir} log --pretty="%H" --simplify-by-decoration`
          sha1s = sha1s.split("\n")
          tags = []
          while tags.size < 2 && sha1s.any?
            sha1 = sha1s.shift
            tag = `git --git-dir=#{safe_git_dir} describe --tags --exact-match #{sha1}`
            tag = tag.strip
            tags << tag unless tag.empty?
          end
          tags.last
        rescue
          raise "Could not get previous tag"
        end

        def git_dir
          @git_dir ||= self.class.find_git_dir(@config[:path])
        end

        # Safely escaped git dir
        def safe_git_dir
          Shellwords.escape(git_dir.to_s)
        end

        # Preload version control data.
        def get_scm_data(ref = @config[:ref])
          @_version = scm_version(ref) || ""
          @_date = scm_date(ref) || Time.now
        end

        # Some hackery to determine if ref is on a tagged version or not
        # @return [String, nil] Will return version number if available, nil otherwise
        def scm_version(ref)
          return nil unless File.exist?(git_dir)

          version = `git --git-dir=#{safe_git_dir} describe --tags #{ref}`

          if $CHILD_STATUS.to_i.positive?
            # HEAD is not a tagged version, get the short SHA1 instead
            version = `git --git-dir=#{safe_git_dir} show #{ref} --format=format:"%h" -s`
          else
            # HEAD is a tagged version, if version is prefixed with "v" it will be stripped off
            version.gsub!(/^v/, "")
          end

          version.strip!
        rescue RuntimeError
          nil
        end

        # Get date of ref from git
        # @return [Time, nil] Returns time if available and parseable, nil otherwise
        def scm_date(ref)
          return nil unless File.exist?(git_dir)

          # Get the date in epoch time
          date = `git --git-dir=#{safe_git_dir} show #{ref} --format=format:"%ct" -s`
          Time.at(date.to_i) if date =~ /\d+/
        rescue RuntimeError
          nil
        end
      end
    end
  end
end
