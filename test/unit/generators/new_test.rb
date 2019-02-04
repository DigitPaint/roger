# encoding: UTF-8

# Generators register themself on the CLI module
require "test_helper"
require "test_construct"

require File.dirname(__FILE__) + "/../../helpers/cli"

module Roger
  # Test Roger Generators
  class GeneratorNewTest < ::Test::Unit::TestCase
    include TestConstruct::Helpers
    include TestCli

    def test_new_generator_exists
      assert_includes Cli::Generate.tasks, "new"
    end

    def test_exits_on_existing_dir
      within_construct do |c|
        c.directory "existingdir"

        assert_raises(SystemExit) { run_command %w(generate new existingdir) }
      end
    end

    def test_with_non_existing_template
      within_construct do
        assert_raises(SystemExit) { run_command %w(generate new mydir -t template) }
      end
    end

    def test_with_default_template
      within_construct do
        run_command %w(generate new mydir)

        assert File.exist?("mydir/Rogerfile")
        assert File.exist?("mydir/Gemfile")
        assert File.exist?("mydir/CHANGELOG")
        assert File.exist?("mydir/.gitignore")
        assert File.directory?("mydir/html")
        assert File.directory?("mydir/partials")
      end
    end

    def test_with_git_template
      within_construct do |c|
        c.directory "template" do |t|
          system("git init -q")
          t.file "gitone"
          system("git add gitone")
          system("git commit -q -am 'test'")
        end

        git_path = "file://#{c + 'template/.git'}"
        run_command %w(generate new mydir -t) << git_path

        assert File.exist?("mydir/gitone")
      end
    end

    def test_with_custom_template
      within_construct do |c|
        c.directory "template" do |t|
          t.file "one"
          t.file "two"
        end

        run_command %w(generate new mydir -t template)

        assert File.exist?("mydir/one")
        assert File.exist?("mydir/two")
      end
    end
  end
end
