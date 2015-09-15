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

    def test_encoding
    end

    # Extension
    def test_source_extension
      mime_types = {
        "html" => "html",
        "html.erb" => "html.erb",
        "css.erb" => "css.erb",
        "json.erb" => "json.erb",
        "sjon.json.erb" => "json.erb",
        "js.erb" => "js.erb"
      }

      mime_types.each do |ext, ext_out|
        assert_equal(
          ext_out,
          Template.new("", @config.update(source_path: @base + "html/file.#{ext}")).source_extension
        )
      end
    end

    def test_target_extension
      mime_types = {
        "html" => "html",
        "html.erb" => "html",
        "css.erb" => "css",
        "json.erb" => "json",
        "js.erb" => "js"
      }

      mime_types.each do |ext, ext_out|
        assert_equal(
          ext_out,
          Template.new("", @config.update(source_path: @base + "html/file.#{ext}")).target_extension
        )
      end
    end

    # Mime type
    def test_target_mime_type
      mime_types = {
        "html" => "text/html",
        "html.erb" => "text/html",
        "css.erb" => "text/css",
        "json.erb" => "application/json"
      }

      mime_types.each do |ext, mime|
        assert_equal(
          mime,
          Template.new("", @config.update(source_path: @base + "html/file.#{ext}")).target_mime_type
        )
      end
    end

    # Front-matter

    def test_front_matter_partial_access
      template = Template.new("---\ntest: yay!\n---\n<%= partial 'test/front_matter' %>", @config)
      assert_equal template.render, "yay!"
    end

    # Environment

    def test_template_env
      template = Template.new("<%= env[:test] %>", @config)
      assert_equal template.render(test: "test"), "test"
    end
  end
end
