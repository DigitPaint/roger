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

    def test_partial_pass_locals
      result = render_erb_template "<%= partial 'test/locals', variable: 'variable' %>"
      assert_equal result, "variable"
    end

    def test_partial_pass_options
      result = render_erb_template "<%= partial 'test/locals', locals: {variable: 'variable'} %>"
      assert_equal result, "variable"
    end

    def test_partial_with_block
      result = render_erb_template "<% partial 'test/yield' do %>CONTENT<% end %>"
      assert_equal result, "B-CONTENT-A"

      result = render_erb_template "<% partial 'test/yield' do %><%= 'CONTENT' %><% end %>"
      assert_equal result, "B-CONTENT-A"

      result = render_erb_template "<% partial 'test/yield' do %>|<%= [1,2].join(',') %>|<% end %>"
      assert_equal result, "B-|1,2|-A"
    end

    def test_partial_with_code_block
      result = render_erb_template "<% partial 'test/array' do [1,2,3,4] end %>"
      assert_equal result, "1234"
    end

    def test_partial_with_block_without_yield
      result = render_erb_template "<% partial 'test/simple' do %>CONTENT<% end %>"
      assert_equal result, "ERB"
    end

    def test_front_matter_partial_access
      result = render_erb_template "---\ntest: yay!\n---\n<%= partial 'test/front_matter' %>"
      assert_equal result, "yay!"
    end

    def test_partial_prevent_recursive
      assert_raise(ArgumentError) do
        render_erb_template "<% partial 'test/recursive' %>"
      end
    end

    def test_partial_prevent_deep_recursive
      assert_raise(ArgumentError) do
        render_erb_template "<% partial 'test/deep_recursive' %>"
      end
    end

    def test_partial_ten_max_depth_recursion
      r = render_erb_template "<%= partial 'test/max_depth', {depth: 0, max_depth: 10} %>"

      assert_match(/Hammertime/, r)

      assert_raise(ArgumentError) do
        render_erb_template "<%= partial 'test/max_depth', {depth: 0, max_depth: 11} %>"
      end
    end

    def test_no_partial_state
      r = render_erb_template '
         <%= begin
               partial "../html/bla/partials/dunno"
               rescue ArgumentError
         end %>
         <%= partial "test/simple" %>'

      assert_match(/ERB/, r)
    end

    def render_erb_template(template)
      @renderer.render(@base + "html/partials/test.html.erb", source: template)
    end
  end
end
