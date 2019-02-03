require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test for Roger Rsync finalizer
  class RsyncTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers

    def setup
      @release = Testing::MockRelease.new

      # Create a file to release in the build dir
      @release.project.construct.file "build/index.html"

      # Set fixed version
      @release.scm.version = "1.0.0"

      # A target dir
      @target_path = setup_construct(chdir: false)

      omit("Skipping rsync test on Windows") if RUBY_PLATFORM.match("mswin") ||
                                                RUBY_PLATFORM.match("mingw")
    end

    # called after every single test
    def teardown
      teardown_construct(@target_path)
      @release.destroy
      @release = nil
    end

    def test_basic_functionality
      finalizer = Roger::Release::Finalizers::Rsync.new

      finalizer.call(
        @release,
        remote_path: @target_path.to_s,
        ask: false
      )

      assert File.exist?(@target_path + "index.html"), @release.target_path.inspect
    end

    def test_rsync_command_works
      finalizer = Roger::Release::Finalizers::Rsync.new

      assert_raise(RuntimeError) do
        finalizer.call(
          @release,
          rsync: "rsync-0123456789", # Let's hope nobody actually has this command
          remote_path: @target_path.to_s,
          ask: false
        )
      end
    end
  end
end
