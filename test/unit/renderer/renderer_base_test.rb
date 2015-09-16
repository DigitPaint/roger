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

    def test_render
      result = @renderer.render("test.html.erb", source: "<%= 'yes' %>")
      assert_equal "yes", result
    end

    # Formats

    def test_render_md
      result = @renderer.render("test.md", source: "# h1")
      assert_equal "<h1>h1</h1>\n", result
    end

    def test_render_md_erb
      result = @renderer.render("test.md.erb", source: "<%= '# h1' %>")
      assert_equal "<h1>h1</h1>\n", result
    end

    # Environment

    def test_template_env
      renderer = Renderer.new({ test: "test" }, @config)
      result = renderer.render("test.erb", source: "<%= env[:test] %>")
      assert_equal "test", result
    end

    # Extension
    def test_source_extension
      mime_types = {
        "html" => "html",
        # "md.erb" => "md.erb",
        "html.erb" => "html.erb",
        "css.erb" => "css.erb",
        "json.erb" => "json.erb",
        "sjon.json.erb" => "json.erb",
        "js.erb" => "js.erb"
      }

      mime_types.each do |ext, ext_out|
        assert_equal(
          ext_out,
          Renderer.source_extension_for(@base + "html/file.#{ext}")
        )
      end
    end

    def test_target_extension
      mime_types = {
        "html" => "html",
        "html.erb" => "html",
        # "md" => "html",
        # "md.erb" => "html",
        "css.erb" => "css",
        "json.erb" => "json",
        "js.erb" => "js"
      }

      mime_types.each do |ext, ext_out|
        assert_equal(
          ext_out,
          Renderer.target_extension_for(@base + "html/file.#{ext}")
        )
      end
    end

    # Mime type
    def test_target_mime_type
      mime_types = {
        "html" => "text/html",
        # "md" => "text/html",
        # "md.erb" => "text/html",
        "html.erb" => "text/html",
        "css.erb" => "text/css",
        "json.erb" => "application/json"
      }

      mime_types.each do |ext, mime|
        assert_equal(
          mime,
          Renderer.target_mime_type_for(@base + "html/file.#{ext}")
        )
      end
    end
  end
end
