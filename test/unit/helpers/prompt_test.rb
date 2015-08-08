require "test_helper"
require "./lib/roger/helpers/prompt"

# Empty prompter class
# This is outside of the Roger namespace by design.
class MyPrompter
  include Roger::Helpers::Prompt

  attr_accessor :project
end

module Roger
  # Test Logging module
  class PromptTest < ::Test::Unit::TestCase
    include Roger::TestCli

    def setup
      @prompter = MyPrompter.new
      @prompter.project = Roger::Testing::MockProject.new
    end

    def teardown
      @prompter.project.destroy
      @prompter = nil
    end

    def test_yes?
      @prompter.project.shell.expects(:yes?).with("Say whut?").returns(true)
      assert @prompter.prompt.yes?("Say whut?")
    end

    def test_yes_with_cli_flag
      @prompter.project.options[:yes] = true
      @prompter.project.shell.expects(:yes?).never
      assert @prompter.prompt.yes?("Say whut?")
    end
  end
end
