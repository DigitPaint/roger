require "./lib/roger/release.rb"
require "test/unit"

class ProcessorsTest < ::Test::Unit::TestCase
  def setup
    Roger::Release::Processors.map.clear
  end

  def test_register_processor
    processor = lambda{|e| raise "ProcessorName" }
    assert Roger::Release::Processors.register(:name, processor)
    assert_equal Roger::Release::Processors.map, {:name => processor}
  end

  def test_register_processor_with_symbol_only_name
    processor = lambda{|e| raise "ProcessorName" }

    assert_raise(ArgumentError){
      Roger::Release::Processors.register("name", processor) 
    }

    assert_raise(ArgumentError){
      Roger::Release::Processors.register("name", processor) 
    }
  end

  def test_register_processor_with_same_name
    processor = lambda{|e| raise "ProcessorName" }
    Roger::Release::Processors.register(:name, processor)

    assert_raise(ArgumentError){
      Roger::Release::Processors.register(:name, processor) 
    }
  end

  def test_register_processor_with_same_contents
    processor = lambda{|e| raise "ProcessorName" }
    Roger::Release::Processors.register(:name, processor)

    assert_nothing_raised{
      Roger::Release::Processors.register(:name2, processor) 
    }

    assert_equal Roger::Release::Processors.map, {:name => processor, :name2 => processor}
  end

end
