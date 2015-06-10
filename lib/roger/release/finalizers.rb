module Roger::Release::Finalizers
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
    fail ArgumentError, "Another finalizer has already claimed the name #{name.inspect}" if map.key?(name)
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
