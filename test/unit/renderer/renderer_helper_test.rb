# encoding: UTF-8

# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/renderer.rb"

module Roger
  # A simple template helper to use for testing
  module RendererHelper
    def a
      "a"
    end

    def from_env(key)
      env[key]
    end
  end

  # Roger template tests
  class RendererHelperTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../../project")
      @config = {
        partials_path: @base + "partials",
        layouts_path: @base + "layouts"
      }
      @template_path = @base + "html"

      @source_path = @base + "html/test.html.erb"

      @renderer = Renderer.new({}, @config)
    end

    def test_register_helper
      Roger::Renderer.helper RendererHelper

      assert Roger::Renderer.helpers.include?(RendererHelper)
    end

    def test_helper_works
      Roger::Renderer.helper RendererHelper

      result = @renderer.render(@source_path, source: "<%= a %>")
      assert_equal "a", result
    end

    def test_helper_has_access_to_env
      Roger::Renderer.helper RendererHelper

      renderer = Renderer.new({ test: "test" }, @config)
      result = renderer.render(@source_path, source: "<%= from_env(:test) %>")
      assert_equal result, "test"
    end
  end
end
