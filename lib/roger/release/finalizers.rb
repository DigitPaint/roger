# The Finalizers will finalize the release. Finalizers can be used to
# copy the release, zip the release or upload the release
module Roger::Release::Finalizers
  # Abstract base finalizer
  class Base
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end

    def call(_release, _options = {})
      fail ArgumentError, "Implement in subclass"
    end
  end

  def self.register(name, finalizer)
    fail ArgumentError, "Finalizer name '#{name.inspect}' already in use" if map.key?(name)
    fail ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)
    map[name] = finalizer
  end

  def self.map
    @_map ||= {}
  end
end

require File.dirname(__FILE__) + "/finalizers/zip"
require File.dirname(__FILE__) + "/finalizers/dir"
require File.dirname(__FILE__) + "/finalizers/rsync"
require File.dirname(__FILE__) + "/finalizers/git_branch"
