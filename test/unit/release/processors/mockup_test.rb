require "test_helper"
require "./lib/roger/release"

# Test Roger Mockup
class MockupTest < ::Test::Unit::TestCase
  def setup
    @base = File.dirname(__FILE__) + "/../../../project"
    @project = Roger::Project.new(@base)
    @release = Roger::Release.new(@project)
    @mockup = Roger::Release::Processors::Mockup.new
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
    @template = Roger::Template.open(@base + "/html/formats/erb.html.erb")
    @processor = Roger::Release::Processors::Mockup.new
  end

  def test_with_html_extension
    assert_equal "bla/test.html", @processor.target_path("bla/test.html", @template).to_s
    assert_equal "test.html", @processor.target_path("test.html", @template).to_s
  end

  def test_with_double_extension
    assert_equal "bla/test.html", @processor.target_path("bla/test.html.erb", @template).to_s
    assert_equal "test.html", @processor.target_path("test.html.erb", @template).to_s
    assert_equal "test.html", @processor.target_path("test.html.test", @template).to_s
  end

  def test_with_unknown_template_mime
    assert_equal "bla/test.rhtml", @processor.target_path("bla/test.rhtml", @template).to_s
    assert_equal "test.rhtml", @processor.target_path("test.rhtml", @template).to_s
  end

  def test_with_template_mime_with_existing_extension
    template = Roger::Template.open(@base + "/html/formats/csv.rcsv")

    assert_equal "bla/test.csv", @processor.target_path("bla/test.rcsv", template).to_s
    assert_equal "test.csv", @processor.target_path("test.erb", template).to_s
  end

  def test_with_template_mime_without_existing_extension
    template = Roger::Template.open(@base + "/html/formats/csv.rcsv")

    assert_equal "bla/test.csv", @processor.target_path("bla/test", template).to_s
    assert_equal "test.csv", @processor.target_path("test", template).to_s
  end
end
