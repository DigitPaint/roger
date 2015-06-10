require "stringio"

module Roger
  module TestCli
    # Capture stdout/stderr output
    def capture
      @_orig_stdout = $stdout
      @_orig_stderr = $stderr

      $stdout = StringIO.new
      $stderr = StringIO.new

      yield

      return [$stdout.string, $stderr.string]
    ensure
      $stdout = @_orig_stdout
      $stderr = @_orig_stderr
    end

    def run_command(args, &_block)
      out, err = capture do
        Cli::Base.start(args, debug: true)
      end
      [out, err]
    end

    def run_command_with_mockupfile(args, &_block)
      project = Project.new(@base_path || File.dirname(__FILE__) + "/../../project", mockupfile_path: false)

      mockupfile = Roger::Mockupfile.new(project)

      yield(mockupfile) if block_given?

      project.mockupfile = mockupfile

      Cli::Base.project = project

      out, err = capture do
        Cli::Base.start(args, debug: true)
      end
      [out, err]
    end
  end
end
