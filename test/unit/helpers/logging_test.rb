require "./lib/roger/helpers/logging"
require "test/unit"
require File.dirname(__FILE__) + "/../../helpers/cli"

# Empty logging class
class Logger
  include Roger::Helpers::Logging

  attr_accessor :project
end

# Test Logging module
class LoggingTest < ::Test::Unit::TestCase
  include Roger::TestCli

  def setup
    @logger = Logger.new
    @logger.project = stub(
      options: {},
      shell: Thor::Shell::Color.new
    )
  end

  def test_log
    out, _err = capture { @logger.log(@logger, "log") }
    assert out.include?("Logger")
    assert out.include?("log")
  end

  def test_log_with_string_part
    out, _err = capture { @logger.log("string_test", "log") }
    assert out.include?("string_test")
    assert out.include?("log")
  end

  def test_log_with_block
    out, _err = capture do
      @logger.log(@logger, "log") do
        @logger.log(@logger, "indent")
      end
    end

    assert out.include?("Logger")
    assert out.include?("log")
    assert out.include?("  Logger : indent"), out
  end

  def test_debug
    out, _err = capture { @logger.debug(@logger, "debug") }
    assert_equal out, ""

    @logger.project.options[:verbose] = true
    out, _err = capture { @logger.debug(@logger, "debug") }
    assert out.include?("Logger")
    assert out.include?("debug")
  end

  # TODO: test if color is outputted as well.
  def test_warn
    out, _err = capture { @logger.warn(@logger, "warn") }
    assert out.include?("Logger")
    assert out.include?("warn")
  end
end
