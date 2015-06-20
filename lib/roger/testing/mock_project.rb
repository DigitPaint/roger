require "test_construct"

module Roger
  module Testing
    # A Mock project. If initialized without a path it will
    # create a test_construct with the following (empty) paths:
    #
    # - html
    # - partials
    # - layouts
    # - releases
    #
    # Use MockProject in testing but never forget to call:
    #
    #     MockProject#destroy
    #
    # in teardown otherwise you pollute your filesystem with build directories
    class MockProject < Project
      include TestConstruct::Helpers

      attr_accessor :construct

      def initialize(path = nil, config = {})
        unless path
          self.construct = setup_construct
          path = construct

          %w(html partials layouts releases).each do |dir|
            construct.directory dir
          end
        end

        # Call super to initialize
        super(path, config)
      end

      # Destroy will remove all files/directories
      def destroy
        teardown_construct(construct) if construct
      end
    end
  end
end
