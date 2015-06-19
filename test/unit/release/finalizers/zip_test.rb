require "test_helper"
require "./lib/roger/release/finalizers/zip"
require "mocha/test_unit"
require "tmpdir"

# Test for Roger Zip finalizer
class ZipTest < Test::Unit::TestCase
  def setup
    # Mock git repo
    @tmp_dir = Pathname.new(Dir.mktmpdir)

    project_path = @tmp_dir + "project"
    FileUtils.mkdir(project_path)

    @release_path = @tmp_dir + "releases"
    FileUtils.mkdir(@release_path)

    Dir.chdir(project_path) do
      `git init`
      `mkdir html`
      `touch html/index.html`
    end

    # Mock release object
    @release_mock = stub(project: stub(path: project_path))

    @release_mock.stubs(
      scm: stub(version: "1.0.0"),
      log: true,
      target_path: @release_path,
      build_path: project_path + "html"
    )
  end

  # called after every single test
  def teardown
    FileUtils.rm_rf(@tmp_dir)
    @release_mock = nil
  end

  def test_basic_functionality
    finalizer = Roger::Release::Finalizers::Zip.new

    finalizer.call(@release_mock)

    assert File.exist?(@release_path + "html-1.0.0.zip")
  end
end
