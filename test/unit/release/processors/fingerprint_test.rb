require "test_helper"
require "roger/testing/mock_release"

require "digest"

module Roger
  # Test UrlRelativizer
  class FingerprintTest < ::Test::Unit::TestCase
    def setup
      @release = Testing::MockRelease.new
      @processor = Roger::Release::Processors::Fingerprint.new

      @release.project.construct.directory "build" do |dir|
        test_css = dir.file "style.css", "body { background: pink; }"
        @hex_test_css = Digest::SHA256.file(test_css).hexdigest

        test_js = dir.file "javascripts/site.js", "console.log('fingerprinting')"
        @hex_test_js = Digest::SHA256.file(test_js).hexdigest
      end
    end

    def teardown
      @release.destroy
      @release = nil
    end

    def test_empty_release_runs
      files = @processor.call(@release)
      assert_equal 0, files.length
    end

    def test_basic_fingerprinting_with_absolute_path
      @release.project.construct.directory "build/sub" do |dir|
        dir.file "test.html", '<link data-fingerprint href="/style.css" rel="stylesheet">'
        dir.file "test2.html", '<link data-fingerprint href="/style.css" rel="stylesheet">'
      end

      @processor.call(@release)

      contents = File.read((@release.build_path + "sub/test.html").to_s)

      output_tag_href = "href=\"/style-#{@hex_test_css}.css\""
      assert contents.include?(output_tag_href)
      assert File.exist? "build/style-#{@hex_test_css}.css"
      assert !(File.exist? "build/style.css")
    end

    def test_basic_fingerprinting_with_relative_path
      @release.project.construct.directory "build/sub" do |dir|
        dir.file "test.html", '<link data-fingerprint href="../style.css" rel="stylesheet">'
      end

      @processor.call(@release)

      contents = File.read((@release.build_path + "sub/test.html").to_s)

      output_tag_href = "href=\"../style-#{@hex_test_css}.css\""
      assert contents.include?(output_tag_href)
      assert File.exist? "build/style-#{@hex_test_css}.css"
      assert !(File.exist? "build/style.css")
    end

    def test_fingerprint_js
      @release.project.construct.directory "build/sub" do |dir|
        dir.file "test.html", '<script data-fingerprint src="/javascripts/site.js">'
      end

      @processor.call(@release)

      contents = File.read((@release.build_path + "sub/test.html").to_s)

      output_tag_href = "src=\"/javascripts/site-#{@hex_test_js}.js\""
      assert contents.include?(output_tag_href)
      assert File.exist? "build/javascripts/site-#{@hex_test_js}.js"
      assert !(File.exist? "build/javascripts/site.js")
    end
  end
end
