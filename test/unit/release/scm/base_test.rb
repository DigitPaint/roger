require "test_helper"
require "mocha/test_unit"

module Roger
  # Test for Roger Base scm
  class BaseScmTest < ::Test::Unit::TestCase
    def setup
      @scm = Roger::Release::Scm::Base.new
    end

    def test_implements_scm_interfase
      assert @scm.respond_to?(:version)
      assert @scm.respond_to?(:date)
      assert @scm.respond_to?(:previous)
    end

    def test_only_abstract_methods
      assert_raise(RuntimeError) { @scm.version }
      assert_raise(RuntimeError) { @scm.date }
      assert_raise(RuntimeError) { @scm.previous }
    end
  end
end
