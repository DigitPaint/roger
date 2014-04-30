class TestGenerator < Roger::Generators::Base

  def do
    puts "Done!"
  end

end

Roger::Generators::Base.register TestGenerator