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

    # Partials

    def test_partial
      template = Template.new("<%= partial 'test/simple' %>", @config)
      assert_equal template.render, "ERB"

      template = Template.new(
        "<%= partial 'test/simple.html' %>",
        @config.update(source_path: @base + "html/test.erb")
      )
      assert_equal template.render, "ERB"
    end

    def test_partial_with_double_template_extensions
      template = Template.new(
        "<%= partial 'test/json.json' %>",
        @config.update(source_path: @base + "html/test.erb")
      )
      assert_equal template.render, "{ key: value }"
    end

    def test_partial_with_preferred_extension
      template = Template.new("<%= partial 'test/json' %>", @config)
      assert_raise(ArgumentError) do
        template.render
      end
      template = Template.new(
        "<%= partial 'test/json' %>",
        @config.update(source_path: @base + "html/test.json.erb")
      )
      assert_equal template.render, "{ key: value }"
    end

    def test_partial_with_block
      template = Template.new("<% partial 'test/yield' do %>CONTENT<% end %>", @config)
      assert_equal template.render, "B-CONTENT-A"

      template = Template.new("<% partial 'test/yield' do %><%= 'CONTENT' %><% end %>", @config)
      assert_equal template.render, "B-CONTENT-A"
    end

    def test_partial_with_block_without_yield
      template = Template.new("<% partial 'test/simple' do %>CONTENT<% end %>", @config)
      assert_equal template.render, "ERB"
    end
  end
end
