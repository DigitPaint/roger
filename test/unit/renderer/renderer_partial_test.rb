# encoding: UTF-8
# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/template.rb"

module Roger
  # Roger template tests
  class RendererPartialTest < ::Test::Unit::TestCase
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

    # Partials

    def test_partial
      result = render_erb_template "<%= partial 'test/simple' %>"
      assert_equal result, "ERB"

      result = render_erb_template "<%= partial 'test/simple.html' %>"
      assert_equal result, "ERB"
    end

    def test_partial_with_double_template_extensions
      result = render_erb_template "<%= partial 'test/json.json' %>"
      assert_equal result, "{ key: value }"
    end

    def test_partial_with_underscored_name
      result = render_erb_template "<%= partial 'test/underscored' %>"
      assert_equal result, "underscored"
    end

    def test_local_partial
      result = render_erb_template "<%= partial 'local' %>"
      assert_equal result, "local"
    end

    def test_partial_with_preferred_extension
      assert_raise(ArgumentError) do
        render_erb_template "<%= partial 'test/json' %>"
      end
      result = @renderer.render(@base + "html/test.json.erb", source: "<%= partial 'test/json' %>")
      assert_equal result, "{ key: value }"
    end

    def test_partial_with_block
      result = render_erb_template "<% partial 'test/yield' do %>CONTENT<% end %>"
      assert_equal result, "B-CONTENT-A"

      result = render_erb_template "<% partial 'test/yield' do %><%= 'CONTENT' %><% end %>"
      assert_equal result, "B-CONTENT-A"
    end

    def test_partial_with_block_without_yield
      result = render_erb_template "<% partial 'test/simple' do %>CONTENT<% end %>"
      assert_equal result, "ERB"
    end

    def test_front_matter_partial_access
      result = render_erb_template "---\ntest: yay!\n---\n<%= partial 'test/front_matter' %>"
      assert_equal result, "yay!"
    end

    def render_erb_template(template)
      @renderer.render(@base + "html/partials/test.html.erb", source: template)
    end
  end
end
