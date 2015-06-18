require "test_helper"
require "./lib/roger/release"

# Test Roger processors
class ProcessorsTest < ::Test::Unit::TestCase
  def setup
    Roger::Release::Processors.map.clear
  end

  def test_register_processor
    processor = ->(_e) { fail "ProcessorName" }
    assert Roger::Release::Processors.register(:name, processor)
    assert_equal Roger::Release::Processors.map, name: processor
  end

  def test_register_processor_with_symbol_only_name
    processor = ->(_e) { fail "ProcessorName" }

    assert_raise(ArgumentError) do
      Roger::Release::Processors.register("name", processor)
    end

    assert_raise(ArgumentError) do
      Roger::Release::Processors.register("name", processor)
    end
  end

  def test_register_processor_with_same_name
    processor = ->(_e) { fail "ProcessorName" }
    Roger::Release::Processors.register(:name, processor)

    assert_raise(ArgumentError) do
      Roger::Release::Processors.register(:name, processor)
    end
  end

  def test_register_processor_with_same_contents
    processor = ->(_e) { fail "ProcessorName" }
    Roger::Release::Processors.register(:name, processor)

    assert_nothing_raised do
      Roger::Release::Processors.register(:name2, processor)
    end

    assert_equal Roger::Release::Processors.map, name: processor, name2: processor
  end
end
