# encoding: UTF-8
# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/renderer.rb"

module Roger
  # Roger template tests
  class RendererContentForTest < ::Test::Unit::TestCase
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

    # Content for parts

    def test_content_for_not_returning_in_template
      content_for_block = 'B<% content_for :one do %><%= "one" %><% end %>A'
      assert_equal "BA", @renderer.render(@source_path) { content_for_block }
    end

    def test_content_for_yield_in_layout
      content_for_block = "---\nlayout: \"yield\"\n---\n"
      content_for_block << "B<% content_for :one do %><%= \"one\" %><% end %>A"

      assert_equal "BAone", @renderer.render(@source_path) { content_for_block }
    end

    def test_content_for_yield_in_layout_without_content_for
      content_for_block = "---\nlayout: \"yield\"\n---\nBA"
      assert_equal "BA", @renderer.render(@source_path) { content_for_block }
    end

    def test_content_for_yield_with_partial_with_block
      template_string = "---\nlayout: \"yield\"\n---\nB"
      template_string << "<% content_for :one do %>"
      template_string << "<% partial 'test/yield' do %>CONTENT<% end %>"
      template_string << "<% end %>A"

      assert_equal "BAB-CONTENT-A", @renderer.render(@source_path) { template_string }
    end
  end
end
