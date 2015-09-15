# encoding: UTF-8
# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/template.rb"

module Roger
  # A simple template helper to use for testing
  module TemplateHelper
    def a
      "a"
    end

    def from_env(key)
      env[key]
    end
  end

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

    def test_register_helper
      Roger::Template.helper TemplateHelper

      assert Roger::Template.helpers.include?(TemplateHelper)
    end

    def test_helper_works
      Roger::Template.helper TemplateHelper

      template = Roger::Template.new("<%= a %>", @config)
      assert_equal template.render, "a"
    end

    def test_helper_has_access_to_env
      Roger::Template.helper TemplateHelper

      template = Roger::Template.new("<%= from_env(:test) %>", @config)
      assert_equal template.render(test: "test"), "test"
    end
  end
end
