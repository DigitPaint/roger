# The generator generator!
class Roger::Generators::GeneratorGenerator < Roger::Generators::Base
  include Thor::Actions

  desc "Create your own generator for roger"
  argument :name, type: :string, required: true, desc: "Name of the new generator"
  argument :path, type: :string, required: true, desc: "Path to generate the new generator"

  def self.source_root
    File.dirname(__FILE__)
  end

  def create_lib_file
    destination = "#{path}/#{name}_generator.rb"
    template("templates/generator.tt", destination)
    say "Add `require #{destination}` to your Rogerfile and run roger generate #{name}."
  end
end

Roger::Generators.register Roger::Generators::GeneratorGenerator
