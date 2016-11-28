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

    def test_render_file_absolute
      result = @renderer.render_file(@base + "html/renderer/file.html.erb")
      assert_equal "file", result
    end

    def test_render_file_relative
      result = @renderer.render(
        @base + "html/dir1/test.html.erb",
        source: "<%= renderer.render_file('../renderer/file.html.erb') %>"
      )
      assert_equal "file", result
    end

    def test_render_file_relative_fails_from_top_level
      assert_raise ArgumentError do
        @renderer.render_file("file.html.erb")
      end
    end

    def test_render_file_prevent_recursive
      assert_raise(ArgumentError) do
        @renderer.render(@base + "html/renderer/recursive.html.erb")
      end
    end

    def test_render_file_pop_nesting
      assert_equal nil, @renderer.current_template
      @renderer.render_file(@base + "html/renderer/file.html.erb")
      assert_equal nil, @renderer.current_template
    end

    # Formats

    def test_render_md
      result = @renderer.render("test.md", source: "# h1")
      assert_equal "<h1>h1</h1>\n", result
    end

    def test_current_remplate
      path = @base + "html/dir1/test.html.erb"
      result = @renderer.render(
        path,
        source: "<%= renderer.current_template.source_path %>"
      )
      assert_equal((@base + "html/dir1/test.html.erb").to_s, result)
    end

    def test_parent_template
      path = @base + "html/dir1/test.html.erb"
      result = @renderer.render(
        path,
        source: "<%= partial 'test/parent_template' %>"
      )
      assert_equal((@base + "html/dir1/test.html.erb").to_s, result)
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
