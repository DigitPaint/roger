require "test_helper"
require "roger/testing/mock_release"

module Roger
  # Test Roger Mockup
  class MockupTest < ::Test::Unit::TestCase
    def setup
      @release = Testing::MockRelease.new
      @mockup = Roger::Release::Processors::Mockup.new
    end

    def teardown
      @release.destroy
      @release = nil
    end

    def test_empty_release_runs
      files = @mockup.call(@release)
      assert_equal 0, files.length
    end
  end

  # Test the target_path function of Mockup
  class MockupTargetPathTest < ::Test::Unit::TestCase
    def setup
      @base = File.dirname(__FILE__) + "/../../../project"
      @processor = Roger::Release::Processors::Mockup.new
    end

    def test_with_html_extension
      assert_output "bla/test.html", "bla/test.html"
      assert_output "test.html", "test.html"
    end

    def test_with_double_extension
      assert_output "bla/test.html", "bla/test.html.erb"
      assert_output "test.html", "test.html.erb"
      assert_output "test.html", "test.html.test"
    end

    def test_with_unknown_template_mime
      assert_output "bla/test.supafriek", "bla/test.supafriek"
      assert_output "test.supafriek", "test.supafriek"
    end

    def test_with_template_mime_with_existing_extension
      assert_equal "bla/test.csv", @processor.target_path("bla/test.rcsv").to_s
      assert_equal "test.csv", @processor.target_path("test.rcsv").to_s
    end

    def test_with_template_mime_without_existing_extension
      assert_output "bla/test", @processor.target_path("bla/test").to_s
      assert_output "test", @processor.target_path("test").to_s
    end

    def assert_output(outfile, infile)
      assert_equal outfile, @processor.target_path(infile).to_s
    end

    def template(path)
      Roger::Template.new("", {}, source_path: path)
    end
  end
end
