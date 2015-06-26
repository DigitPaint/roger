require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test Roger Injector
  class InjectorTest < ::Test::Unit::TestCase
    def setup
      @release = Testing::MockRelease.new

      # Create a file to release in the build dir
      @release.project.construct.directory "build" do |dir|
        @target_file = dir.file("out", "aVARb")
        @source_file = dir.file("in", "IN")
        @source_md_file = dir.file("md", "*a*")
      end
    end

    def teardown
      @release.destroy
    end

    def test_string_injection
      injector = Roger::Release::Injector.new(
        { "VAR" => "1" },
        into: ["out"]
      )

      injector.call(@release)

      assert_equal "a1b", File.read(@target_file.to_s)
    end

    def test_regex_injection
      injector = Roger::Release::Injector.new(
        { /V.R/ => "1" },
        into: ["out"]
      )

      injector.call(@release)

      assert_equal "a1b", File.read(@target_file.to_s)
    end

    def test_file_injection
      injector = Roger::Release::Injector.new(
        { "VAR" => { file: @source_file.to_s } },
        into: ["out"]
      )

      injector.call(@release)

      assert_equal "aINb", File.read(@target_file.to_s)
    end

    def test_template_injection
      injector = Roger::Release::Injector.new(
        { "VAR" => { file: @source_md_file.to_s, processor: "md" } },
        into: ["out"]
      )

      injector.call(@release)

      assert_equal "a<p><em>a</em></p>\nb", File.read(@target_file.to_s)
    end
  end
end
