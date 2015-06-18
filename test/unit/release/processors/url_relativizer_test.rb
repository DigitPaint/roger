require File.dirname(__FILE__) + "/../../../helpers/release_test_case"

module Roger
  # Test Roger Mockup
  class UrlRelativizerTest < ReleaseTestCase
    def setup
      super
      @processor = Roger::Release::Processors::UrlRelativizer.new
    end

    def test_empty_release_runs
      files = @processor.call(release)
      assert_equal 0, files.length
    end

    def test_basic_relativization
      build_path.directory "sub" do |dir|
        dir.file "test.html", "<a href='/test.html'>link</a>"
      end
      build_path.file "test.html"

      files = @processor.call(release)
      assert_equal 2, files.length

      contents = File.read((build_path + "sub/test.html").to_s)
      assert contents.include?("../test.html")
    end
  end
end
