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

    # Content for parts

    def test_content_for_not_returning_in_template
      content_for_block = 'B<% content_for :one do %><%= "one" %><% end %>A'

      template = Template.new(
        content_for_block,
        @config.update(source_path: @base + "html/test.erb")
      )
      assert_equal template.render, "BA"
    end

    def test_content_for_yield_in_layout
      content_for_block = "---\nlayout: \"yield\"\n---\n"
      content_for_block << "B<% content_for :one do %><%= \"one\" %><% end %>A"

      template = Template.new(content_for_block, @config)
      assert_equal template.render, "BAone"
    end

    def test_content_for_yield_in_layout_without_content_for
      content_for_block = "---\nlayout: \"yield\"\n---\nBA"

      template = Template.new(content_for_block, @config)
      assert_equal template.render, "BA"
    end

    def test_content_for_yield_with_partial_with_block
      template_string = "---\nlayout: \"yield\"\n---\nB"
      template_string << "<% content_for :one do %>"
      template_string << "<% partial 'test/yield' do %>CONTENT<% end %>"
      template_string << "<% end %>A"

      template = Template.new(template_string, @config)
      assert_equal template.render, "BAB-CONTENT-A"
    end
  end
end
