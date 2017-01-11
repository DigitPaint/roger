# Generator scope
module Generators
  # Simple Mock generator
  class MockedGenerator < Roger::Generators::Base
    desc "@mocked description"
    argument :path, type: :string, required: false, desc: "Path to generate project into"
    argument :another_arg, type: :string, required: false, desc: "Mocked or what?!"

    def test
      # Somewhat ugly way of checking
      raise NotImplementedError
    end
  end

  Roger::Generators.register :mocked, MockedGenerator

  # Simple Mocku generator that has a project
  class MockedWithProjectGenerator < Roger::Generators::Base
    desc "Returns a project"
    def test
      # Somewhat ugly way of checking
      raise StandardError if @project
    end
  end
end
