# A Generator for testing purposes; doesn't do much
class TestGenerator < Roger::Generators::Base
  def do
    puts "Done!"
  end
end

Roger::Generators.register TestGenerator
