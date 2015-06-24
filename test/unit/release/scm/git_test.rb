require "test_helper"
require "mocha/test_unit"
require "test_construct"

module Roger
  # Test for Roger Zip finalizer
  class GitScmTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers

    def setup
      @construct = setup_construct

      @scm = Roger::Release::Scm::Git.new(path: @construct)

      @construct.file "test.html"

      # Setup git
      `git init`
      `git add *`
      `git commit -m "Commit 1"`
      `git tag v0.1.0`

      @construct.file "test2.html"

      `git add *`
      `git commit -m "Commit 2"`
      `git tag v1.0.0`
    end

    def teardown
      teardown_construct(@construct)
    end

    def test_implements_scm_interfase
      assert @scm.respond_to?(:version)
      assert @scm.respond_to?(:date)
      assert @scm.respond_to?(:previous)
    end

    def test_version
      assert_equal "1.0.0", @scm.version
    end

    def test_previous
      assert_equal "0.1.0", @scm.previous.version
    end

    def test_date
      now = Time.now
      date = @scm.date
      assert_equal now.day, date.day
      assert_equal now.month, date.month
      assert_equal now.year, date.year
      assert_equal now.hour, date.hour
      assert_equal now.min, date.min
    end
  end
end
