require "shellwords"

# Generator to create a new HTML mockup based on an existing skeleton
class Roger::Generators::NewGenerator < Thor::Group
  include Thor::Actions

  desc "Create a new HTML mockup based on an existing skeleton"

  argument :path, type: :string, required: true, desc: "Path to generate mockup into"

  class_option(
    :template,
    type: :string,
    aliases: ["-t"],
    desc: "Template to use, can be a path or a git remote, uses built in minimal as default"
  )

  attr_reader :source_paths

  def setup_variables
    self.destination_root = path

    @source_paths = []

    # Stuff to rm -rf later
    @cleanup = []
  end

  def validate_path_is_empty
    return unless File.directory?(destination_root)

    say "Directory #{destination_root} already exists, please only use this to create new mockups"
    exit(1)
  end

  def validate_template_path
    template = options[:template] || File.dirname(__FILE__) + "/../../../examples/default_template"

    if File.exist?(template)
      say "Taking template from #{template}"
      @source_paths << template
    else
      say "Getting template from git remote #{template}"
      @source_paths << git_clone_template(template)
    end
  rescue StandardError => e
    puts e
    puts e.backtrace.join("\n")
  end

  def create_mockup
    directory(".", ".")
  end

  protected

  def git_clone_template(template)
    tmp_dir = temp_directory

    if run("git clone --depth=1 #{Shellwords.escape(template)} #{tmp_dir}")
      say "Cloned template from #{template}"
      run("rm -rf #{tmp_dir + '.git'}")
      @cleanup << tmp_dir.to_s
    else
      say "Template path #{template} doesn't seem to be a git remote or a local path"
      exit(1)
    end

    tmp_dir
  end

  def temp_directory
    # Hack to create temp directory
    t = Tempfile.new("htmlmockup-generate-new")
    tmp_dir = Pathname.new(t.path)
    t.close
    t.unlink
    tmp_dir
  end
end

Roger::Generators.register Roger::Generators::NewGenerator
