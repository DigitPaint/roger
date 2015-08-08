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
    end

    # called after every single test
    def teardown
      teardown_construct(@target_path)
      @release.destroy
      @release = nil
    end

    def test_basic_functionality
      finalizer = Roger::Release::Finalizers::Rsync.new(
        remote_path: @target_path.to_s,
        ask: false
      )

      finalizer.call(@release)

      assert File.exist?(@target_path + "index.html"), @release.target_path.inspect
    end

    def test_rsync_command_works
      finalizer = Roger::Release::Finalizers::Rsync.new(
        rsync: "rsync-0123456789", # Let's hope nobody actually has this command
        remote_path: @target_path.to_s,
        ask: false
      )

      assert_raise(RuntimeError) do
        finalizer.call(@release)
      end
    end

    def test_rsync_with_question
      host = "" # Is left empty in test setup
      question = "Do you wish to upload to #{host}? [y/N]: "

      @release.project.shell.expects(:yes?).with(question).returns(true)

      finalizer = Roger::Release::Finalizers::Rsync.new(
        remote_path: @target_path.to_s,
        ask: true
      )

      finalizer.call(@release)

      assert File.exist?(@target_path + "index.html"), @release.target_path.inspect
    end

    def test_rsync_with_cli_flag
      @release.project.options[:yes] = true
      @release.project.shell.expects(:yes?).never

      finalizer = Roger::Release::Finalizers::Rsync.new(
        remote_path: @target_path.to_s,
        ask: true
      )

      finalizer.call(@release)

      assert File.exist?(@target_path + "index.html"), @release.target_path.inspect
    end
  end
end
