require "test_helper"
require "./lib/roger/release"

module Roger
  # Test Roger processors
  class ProcessorsTest < ::Test::Unit::TestCase
    def setup
      @origmap = Roger::Release::Processors.map.dup
      Roger::Release::Processors.map.clear
    end

    def teardown
      Roger::Release::Processors.map.clear
      Roger::Release::Processors.map.update(@origmap)
    end

    def test_register_processor
      processor = ->(_e) { raise "ProcessorName" }
      assert Roger::Release::Processors.register(:name, processor)
      assert_equal Roger::Release::Processors.map, name: processor
    end

    def test_register_processor_with_symbol_only_name
      processor = ->(_e) { raise "ProcessorName" }

      assert_raise(ArgumentError) do
        Roger::Release::Processors.register("name", processor)
      end

      assert_raise(ArgumentError) do
        Roger::Release::Processors.register("name", processor)
      end
    end

    def test_register_processor_with_same_name
      processor = ->(_e) { raise "ProcessorName" }
      Roger::Release::Processors.register(:name, processor)

      assert_raise(ArgumentError) do
        Roger::Release::Processors.register(:name, processor)
      end
    end

    def test_register_processor_with_same_contents
      processor = ->(_e) { raise "ProcessorName" }
      Roger::Release::Processors.register(:name, processor)

      assert_nothing_raised do
        Roger::Release::Processors.register(:name2, processor)
      end

      assert_equal Roger::Release::Processors.map, name: processor, name2: processor
    end
  end
end
