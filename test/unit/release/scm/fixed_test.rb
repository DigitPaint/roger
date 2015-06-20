require "test_helper"
require "mocha/test_unit"

module Roger
  # Test for Roger Zip finalizer
  class FixedScmTest < ::Test::Unit::TestCase
    def setup
      @scm = Roger::Release::Scm::Fixed.new
    end

    def test_implements_scm_interfase
      assert @scm.respond_to?(:version)
      assert @scm.respond_to?(:date)
      assert @scm.respond_to?(:previous)
    end

    def test_has_defaults
      assert_equal "0.0.0", @scm.version
      assert_equal "0.0.0", @scm.previous
      assert @scm.date
    end

    def test_input_equals_output
      assert_equal "0.0.0", @scm.version
      @scm.version = "1"
      assert_equal "1", @scm.version
    end
  end
end
