require "stringio"

module Roger
  # A shell that does not output to stdout but will
  # just have two StringIO objects which can be accessed by using
  # #stdout and #stderr methods.
  class MockShell < Thor::Shell::Basic
    public :stdout, :stderr

    def stdout
      @_stdout ||= StringIO.new
    end

    def stderr
      @_stderr ||= StringIO.new
    end
  end
end
