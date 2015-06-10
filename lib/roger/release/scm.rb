module Roger::Release::Scm
  class Base
    attr_reader :config

    def initialize(config = {})
      @config = config
    end

    # Returns the release version string from the SCM
    #
    # @return String The current version string
    def version
      fail "Implement in subclass"
    end

    # Returns the release version date from the SCM
    def date
      fail "Implement in subclass"
    end

    # Returns a Release::Scm object with the previous version's data
    #
    # @return Roger::Release::Scm The previous version
    def previous
      fail "Implement in subclass"
    end
  end
end

require File.dirname(__FILE__) + "/scm/git"
