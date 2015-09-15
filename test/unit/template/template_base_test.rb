# encoding: UTF-8
# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/template.rb"

module Roger
  # Roger template tests
  class TemplateTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../../project")
      @config = {
        partials_path: @base + "partials",
        layouts_path: @base + "layouts",
        source_path: @base + "html/test.html.erb"
      }
      @template_path = @base + "html"
    end

    def test_render
      template = Template.new("<%= 'test' %>", {}, source_path: "test.erb")
      assert_equal "test", template.render
    end

    def test_render_with_block
      template = Template.new("<%= yield %>", {}, source_path: "test.erb")
      assert_equal "inner", template.render { "inner" }
    end
  end
end
