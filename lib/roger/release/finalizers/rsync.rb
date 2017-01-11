require "shellwords"
require "English"

module Roger::Release::Finalizers
  # Finalizes the release by uploading your project with rsync to a remote server
  #
  # @see RsyncFinalizer#initialize for options
  #
  class Rsync < Base
    self.name = :rsync

    # @param Hash options The options
    #
    # @option options String :rsync The Rsync command to run (default is "rsync")
    # @option options String :remote_path The remote path to upload to
    # @option options String :host The remote host to upload to
    # @option options String :username The remote username to upload to
    # @option options Boolean :ask Prompt the user before uploading (default is true)
    def default_options
      {
        rsync: "rsync",
        remote_path: "",
        host: nil,
        username: nil,
        ask: true
      }
    end

    def perform
      # Validate options
      validate_options!

      return unless prompt_for_upload

      check_rsync_command(@options[:rsync])

      local_path = @release.build_path.to_s
      remote_path = @options[:remote_path]

      local_path += "/" unless local_path =~ %r{/\Z}
      remote_path += "/" unless remote_path =~ %r{/\Z}

      release.log(self, "Starting upload of #{(@release.build_path + '*')} to #{@options[:host]}")
      rsync(@options[:rsync], local_path, remote_path)
    end

    protected

    def check_rsync_command(command)
      `#{command} --version`
    rescue Errno::ENOENT
      raise "Could not find rsync in #{command.inspect}"
    end

    def rsync(command, local_path, remote_path)
      target_path = remote_path
      target_path = "#{@options[:host]}:#{target_path}" if @options[:host]
      target_path = "#{@options[:username]}@#{target_path}" if @options[:username]

      command = [
        options[:rsync],
        "-az",
        Shellwords.escape(local_path),
        Shellwords.escape(target_path)
      ]

      # Run rsync
      output = `#{command.join(" ")}`

      # Check if rsync succeeded
      raise "Rsync failed.\noutput:\n #{output}" unless $CHILD_STATUS.success?
    end

    def prompt_for_upload
      !options[:ask] ||
        prompt("Do you wish to upload to #{@options[:host]}? [y/N]: ") =~ /\Ay(es)?\Z/
    end

    def validate_options!
      must_have_keys = [:remote_path]
      return if (@options.keys & must_have_keys).size == must_have_keys.size

      release.log(self, "Missing options: #{(must_have_keys - @options.keys).inspect}")
      raise "Missing keys: #{(must_have_keys - @options.keys).inspect}"
    end

    def prompt(question = "Do you wish to continue?")
      print(question)
      $stdin.gets.strip
    end
  end
end

Roger::Release::Finalizers.register(Roger::Release::Finalizers::Rsync)
