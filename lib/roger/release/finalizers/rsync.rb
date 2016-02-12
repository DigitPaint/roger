require "shellwords"
require "English"

module Roger::Release::Finalizers
  # Finalizes the release by uploading your project with rsync to a remote server
  #
  # @see RsyncFinalizer#initialize for options
  #
  class Rsync < Base
    # @param Hash options The options
    #
    # @option options String :rsync The Rsync command to run (default is "rsync")
    # @option options String :remote_path The remote path to upload to
    # @option options String :host The remote host to upload to
    # @option options String :username The remote username to upload to
    # @option options Boolean :ask Prompt the user before uploading (default is true)
    def initialize(options = {})
      @options = {
        rsync: "rsync",
        remote_path: "",
        host: nil,
        username: nil,
        ask: true
      }.update(options)
    end

    def call(release, options = {})
      options = @options.dup.update(options)

      # Validate options
      validate_options!(release, options)

      # Check if the user wants to upload this release
      return unless prompt_for_upload(options, release)

      check_rsync_command(options[:rsync])

      local_path = release.build_path.to_s
      remote_path = options[:remote_path]

      local_path += "/" unless local_path =~ %r{/\Z}
      remote_path += "/" unless remote_path =~ %r{/\Z}

      release.log(self, "Starting upload of #{(release.build_path + '*')} to #{options[:host]}")
      rsync(options[:rsync], local_path, remote_path, options)
    end

    protected

    def check_rsync_command(command)
      `#{command} --version`
    rescue Errno::ENOENT
      raise "Could not find rsync in #{command.inspect}"
    end

    def rsync(command, local_path, remote_path, options = {})
      target_path = remote_path
      target_path = "#{options[:host]}:#{target_path}" if options[:host]
      target_path = "#{options[:username]}@#{target_path}" if options[:username]

      command = [
        options[:rsync],
        "-az",
        Shellwords.escape(local_path),
        Shellwords.escape(target_path)
      ]

      # Run rsync
      output = `#{command.join(" ")}`

      # Check if rsync succeeded
      fail "Rsync failed.\noutput:\n #{output}" unless $CHILD_STATUS.success?
    end

    # Before we actually start rsyncing, user input is required
    # this avoids accidental uploads
    # this prompt is skipped if
    #   > the rsync processor is given false for options[:ask]
    #   > the project option[:yes] is set to true
    def prompt_for_upload(options, release)
      !options[:ask] ||
        release.prompt.yes?("Do you wish to upload to #{options[:host]}? [y/N]: ")
    end

    def validate_options!(release, options)
      must_have_keys = [:remote_path]
      return if (options.keys & must_have_keys).size == must_have_keys.size

      release.log(self, "Missing options: #{(must_have_keys - options.keys).inspect}")
      fail "Missing keys: #{(must_have_keys - options.keys).inspect}"
    end
  end
end

Roger::Release::Finalizers.register(:rsync, Roger::Release::Finalizers::Rsync)
