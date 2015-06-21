module Roger
  class Release
    module Scm
      # The Fixed SCM implementation for Roger release
      # Here you define everything in the config or set it later with the different accessors.
      class Fixed < Base
        attr_accessor :version, :date, :previous

        # @option config [String] :version Version to use (default "0.0.0")
        # @option config [Time] :date Date to use (default Time.now)
        # @option config [String] :previous Previous version to use (default "0.0.0")
        def initialize(config = {})
          super(config)

          self.version = config[:version] || "0.0.0"
          self.date = config[:date] || Time.now
          self.previous = config[:previous] || "0.0.0"
        end
      end
    end
  end
end
