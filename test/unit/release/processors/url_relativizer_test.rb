require "test_helper"
require "./lib/roger/release"

class UrlRelativizerTest < ::Test::Unit::TestCase
  def setup
    @base = File.dirname(__FILE__) + "/../../../project"
    @project = Roger::Project.new(@base, mockupfile_path: false)
    @mockupfile = Roger::Mockupfile.new(@project)
    @urlrelativizer = Roger::Release::Processors::UrlRelativizer.new
  end

  def teardown
    FileUtils.remove_dir(@base + "/releases")
  end

  # Should be reconsidered, very hard to test
  def test_match_option_relativizer
    @mockupfile.release(blank: true) do |r|
      r.use @urlrelativizer, match: ["static/relative.html.erb"]
      r.finalize :dir
    end

    file_before = File.read(@base + "/html/static/relative.html.erb")

    # Run
    @project.release.run!

    # Maybe the release object should known its full name?
    name = ["html", @project.release.scm.version].join("-")
    target_path = @project.release.target_path + name

    file_after = File.read(target_path.join("static/relative.html.erb"))

    assert_not_equal file_before, file_after
  end

  def test_skip_option_relativizer
    @mockupfile.release(blank: true) do |r|
      r.use @urlrelativizer, skip: ["static/non-relative.html.erb"]
      r.finalize :dir
    end

    file_before = File.read(@base + "/html/static/non-relative.html.erb")

    # Run
    @project.release.run!

    # Maybe the release object should known its full name?
    name = ["html", @project.release.scm.version].join("-")
    target_path = @project.release.target_path + name

    file_after = File.read(target_path.join("static/non-relative.html.erb"))

    assert_equal file_before, file_after
  end
end
