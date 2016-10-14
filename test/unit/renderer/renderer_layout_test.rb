# encoding: UTF-8
# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/renderer.rb"

module Roger
  # Roger template tests
  class RendererBaseTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../../project")
      @config = {
        partials_path: @base + "partials",
        layouts_path: @base + "layouts",
        source_path: @base + "html/test.html.erb"
      }
      @template_path = @base + "html"

      @renderer = Renderer.new({}, @config)
    end

    def test_basic_layout
      template = "---\nlayout: \"yield\"\n---\nTEMPLATE"
      assert_equal "TEMPLATE", render_erb_template(template)
    end

    def test_layout_with_partial
      template = "---\nlayout: \"partial\"\n---\nTEMPLATE"
      assert_equal "TEMPLATEERB", render_erb_template(template)
    end

    def test_layout_with_block_partial
      template = "---\nlayout: \"partial_with_block\"\n---\nTEMPLATE"
      assert_equal "TEMPLATEB-PARTIAL-A", render_erb_template(template)
    end

    def render_erb_template(template)
      @renderer.render(@base + "html/layouts/test.html.erb", source: template)
    end
  end
end
