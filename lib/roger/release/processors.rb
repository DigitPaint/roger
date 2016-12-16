# Processors can perform any action on a release
module Roger::Release::Processors
  extend Roger::Helpers::Registration

  # Abstract Processor class
  class Base
    attr_reader :options, :release

    class << self
      attr_writer :name

      # Name of this processor
      def name
        @name || raise(ArgumentError, "Implement in subclass")
      end
    end

    # Default options for this processor
    def default_options
      {}
    end

    # Name of this processor.
    # - Can be set by setting the :name config in the release block
    # - Can be overwritten in implementation if needed
    def name
      options && options[:name] || self.class.name
    end

    def call(release, options = {})
      @release = release
      @options = {}.update(default_options)
      @options.update(options) if options
      @options.update(my_project_options)

      # Stop immideatly if we've been disabled
      return if @options[:disable]

      perform
    end

    protected

    # The options passed through the project. This can contain
    # command line options
    def my_project_options
      project_options = release.project.options
      project_options[:release] && project_options[:release][name] || {}
    end

    def perform
      raise ArgumentError, "Implement in subclass"
    end
  end
end

require File.dirname(__FILE__) + "/processors/mockup"
require File.dirname(__FILE__) + "/processors/url_relativizer"
