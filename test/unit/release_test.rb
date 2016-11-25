# Generators register themself on the CLI module
require "test_helper"
require "roger/testing/mock_project"

module Roger
  # Test Roger Release
  class ReleaseTest < ::Test::Unit::TestCase
    def setup
      @project = Testing::MockProject.new
      @rogerfile = Roger::Rogerfile.new(@project)
    end

    def teardown
      @project.destroy
    end

    def test_run_should_set_project_mode
      assert_equal @project.mode, nil

      # Running a blank release
      @rogerfile.release(blank: true) do |r|
        r.use proc{|release|
          assert_equal release.project.mode, :release
        }
      end

      @project.release.run!
      assert_equal @project.mode, nil
    end

    def test_blank_release_should_have_no_processors_and_finalizers
      @rogerfile.release(blank: true)
      @project.release.run!

      assert @project.release.stack.empty?
    end

    def test_release_should_add_mockup_processor_as_first_by_default
      release = @rogerfile.release
      release.run!

      assert !release.stack.empty?
      assert_equal Roger::Release::Processors::Mockup, release.stack.first.first.class
    end

    def test_release_should_add_url_relativizer_by_default
      release = @rogerfile.release
      release.run!

      assert !release.stack.empty?
      assert_equal Roger::Release::Processors::UrlRelativizer, release.stack[-2].first.class
    end

    def test_release_should_add_dir_finalizer_by_default
      release = @rogerfile.release
      release.run!

      assert !release.stack.empty?
      assert_equal Roger::Release::Finalizers::Dir, release.stack.last.first.class
    end

    #  =============================
    #  = Copy source to build test =
    #  =============================

    def test_copy_using_cp
      @rogerfile.release(blank: true, cleanup_build: false)
      @project.construct.file "html/test.txt"
      @project.release.run!

      build_path = @project.release.build_path

      assert build_path.exist?
      assert_equal 1, build_path.children.size
      assert_equal build_path + "test.txt", build_path.children.first
    end

    def test_copy_using_fileutils
      @rogerfile.release(cp: nil, blank: true, cleanup_build: false)
      @project.construct.file "html/test.txt"
      @project.release.run!

      build_path = @project.release.build_path

      assert build_path.exist?
      assert_equal 1, build_path.children.size
      assert_equal build_path + "test.txt", build_path.children.first
    end

    def test_release_should_use_html_path_as_default_source
      # Create a file in the web dir
      @project.construct.file "web/index.html"
      @project.html_path = @project.path + "web"

      # Blank release, just the copying
      @rogerfile.release(blank: true, cleanup_build: false)

      @project.release.run!

      build_path = @project.release.build_path
      assert build_path.exist?
      assert_equal 1, build_path.children.size
      assert_equal build_path + "index.html", build_path.children.first
    end

    #  ============================
    #  = Banner and comment tests =
    #  ============================

    def test_default_banner
      release = @rogerfile.release(scm: :fixed)

      # Set fixed version
      date = Time.now
      release.scm.version = "1.0.0"
      release.scm.date = date

      lines = release.banner.split("\n")

      assert_equal "/* ====================== */", lines[0]
      assert_equal "/* = Version : 1.0.0    = */", lines[1]
      assert_equal "/* = Date  : #{date.strftime('%Y-%m-%d')} = */", lines[2]
      assert_equal "/* ====================== */", lines[3]
    end

    def test_banner
      release = @rogerfile.release(scm: :fixed)

      banner = release.banner do
        "BANNER"
      end

      assert_equal "/* BANNER */", banner
    end

    def test_comment_per_line
      release = @rogerfile.release

      options = {
        style: :css,
        per_line: true
      }

      assert_equal "/* a */", release.comment("a", options)
      assert_equal "/* a */\n/* b */", release.comment("a\nb", options)
    end

    def test_comment_html
      release = @rogerfile.release

      options = {
        style: :html,
        per_line: false
      }

      assert_equal "<!-- a -->", release.comment("a", options)
      assert_equal "<!-- a\nb -->", release.comment("a\nb", options)
    end

    def test_comment_css
      release = @rogerfile.release

      options = {
        style: :css,
        per_line: false
      }

      assert_equal "/* a */", release.comment("a", options)
      assert_equal "/* a\nb */", release.comment("a\nb", options)
    end

    def test_comment_js
      release = @rogerfile.release

      options = {
        style: :js,
        per_line: false
      }

      assert_equal "/* a */", release.comment("a", options)
      assert_equal "/* a\nb */", release.comment("a\nb", options)
    end

    #  ======================
    #  = Get callable tests =
    #  ======================

    def test_get_callable
      p = -> {}
      assert_equal Release.get_callable(p, {}), p
      assert_raise(ArgumentError) { Release.get_callable(nil, {}) }
    end

    def test_get_callable_with_map
      p = -> {}
      map = {
        lambda: p
      }

      assert_equal Release.get_callable(:lambda, map), p
      assert_raise(ArgumentError) { Release.get_callable(:huh, map) }
    end

    # A Release class that is valid
    class Works
      def call; end
    end

    # A Release class that is invalid
    class Breaks
    end

    def test_get_callable_with_class
      assert Release.get_callable(Works, {}).instance_of?(Works)
      assert_raise(ArgumentError) { Release.get_callable(Breaks, {}) }
    end
  end
end
