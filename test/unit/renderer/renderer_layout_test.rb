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

    def test_missing_layout
      template = "---\nlayout: \"not-there\"\n---\nTEMPLATE"

      assert_raise ArgumentError do
        render_erb_template(template)
      end
    end

    def test_default_layout
      template = "TEMPLATE"
      default_layout = {
        "html.erb" => "bracket"
      }

      assert_equal "[TEMPLATE]", render_erb_template(template, layout: default_layout)
    end

    def test_default_layout_is_overriden_by_frontmatter
      template = "---\nlayout: \"yield\"\n---\nTEMPLATE"
      default_layout = {
        "html.erb" => "bracket"
      }

      assert_equal "TEMPLATE", render_erb_template(template, layout: default_layout)
    end

    def test_default_layout_can_by_disabled_in_frontmatter
      template = "---\nlayout: \n---\nTEMPLATE"
      default_layout = {
        "html.erb" => "bracket"
      }

      assert_equal "TEMPLATE", render_erb_template(template, layout: default_layout)
    end

    def test_default__layouts_is_skipped_for_other_extensions_types
      template = "TEMPLATE"
      default_layout = {
        "html.erb" => "bracket"
      }

      assert_equal "TEMPLATE", render_css_template(template, layout: default_layout)
    end

    def render_erb_template(template, options = {})
      render_abstract_template(@base + "html/layouts/test.html.erb", template, options)
    end

    def render_css_template(template, options = {})
      render_abstract_template(@base + "html/layouts/test.css.erb", template, options)
    end

    def render_abstract_template(filename, template, options)
      options = {}.update(options).update(source: template)
      @renderer.render(filename, options)
    end
  end
end
