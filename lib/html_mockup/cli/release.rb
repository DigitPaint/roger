module Roger
  class Cli::Release < Cli::Command

    desc "Release the current project"

    def release
      @project.release.run!
    end
  end
end