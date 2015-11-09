# Generators register themself on the CLI module
require "test_helper"
require "./lib/roger/resolver.rb"

module Roger
  # Test Roger resolver
  class ResolverTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../project/html")
      @resolver = Roger::Resolver.new(@base)
    end

    def assert_find(exp, search)
      exp = @base + exp unless exp.nil?
      assert_equal exp, @resolver.find_template(search)
    end

    def test_find_template_index_path
      assert_find "formats/index.html", "formats"
    end

    def test_find_template_html_without_extension
      assert_find "formats/index.html", "formats/index"
      assert_find "formats/erb.html.erb", "formats/erb"
    end

    def test_find_template_with_template_extension
      assert_find "formats/markdown.md", "formats/markdown"
    end

    def test_find_template_with_double_extensions
      assert_find "formats/erb.html.erb", "formats/erb"
      assert_find "formats/erb.html.erb", "formats/erb.html"
      assert_find "formats/erb.html.erb", "formats/erb.html.erb"

      assert_find "formats/markdown-erb.md.erb", "formats/markdown-erb"
      assert_find "formats/markdown-erb.md.erb", "formats/markdown-erb.md"
      assert_find "formats/markdown-erb.md.erb", "formats/markdown-erb.md.erb"
    end

    def test_not_find_template_with_non_matching_double_extension
      assert_find "formats/json.json.erb", "formats/json.json"
      assert_find nil, "formats/json.html"
    end

    def test_find_template_with_aliassed_extension
      assert_find "formats/markdown-erb.md.erb", "formats/markdown-erb.html"
      assert_find "formats/markdown.md", "formats/markdown.html"
    end

    def test_find_template_exact_match
      assert_find "formats/index.html", "formats/index.html"
      assert_find "formats/erb.html.erb", "formats/erb.html.erb"
    end

    def test_find_template_with_preferred_extension
      assert_equal(
        @resolver.find_template("formats/preferred", prefer: "html"),
        @base + "formats/preferred.html.erb"
      )

      assert_equal(
        @resolver.find_template("formats/preferred", prefer: "json"),
        @base + "formats/preferred.json.erb"
      )
    end

    def test_path_to_url
      assert_equal "/formats/erb.html.erb", @resolver.path_to_url(@base + "formats/erb.html.erb")
    end

    def test_path_to_url_relative_to_relative_path
      assert_equal(
        @resolver.path_to_url(@base + "formats/erb.html.erb", "../front_matter/erb.html.erb"),
        "../formats/erb.html.erb"
      )
    end

    def test_path_to_url_relative_to_absolute_path
      assert_equal(
        @resolver.path_to_url(
          @base + "formats/erb.html.erb",
          @base.realpath + "front_matter/erb.html.erb"
        ),
        "../formats/erb.html.erb"
      )
    end
  end

  # Test resolver with multiple load paths
  class ResolverMultipleTest < ::Test::Unit::TestCase
    def setup
      @base = Pathname.new(File.dirname(__FILE__) + "/../project")
      @resolver = Roger::Resolver.new([@base + "html", @base + "partials"])
    end

    def assert_find(exp, search)
      assert_equal @base + exp, @resolver.find_template(search)
    end

    def test_add_load_path
      @resolver.load_paths << @base + "henk"

      assert_equal @resolver.load_paths, [@base + "html", @base + "partials", @base + "henk"]
    end

    def test_find_template_path
      assert_find "html/formats/index.html", "formats/index"
      assert_find "partials/test/simple.html.erb", "test/simple"
    end

    def test_find_template_path_ordered
      assert_find "html/formats/erb.html.erb", "formats/erb"

      @resolver.load_paths.reverse!

      assert_find "partials/formats/erb.html.erb", "formats/erb"
    end
  end
end
