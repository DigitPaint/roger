module Roger::Release::Finalizers
  class Base    
    
    def initialize(options = {})
      @options = {}
      @options.update(options) if options
    end
    
    def call(release, options = {})
      raise ArgumentError, "Implement in subclass"
    end
  end

  def self.register(name, finalizer)
    raise ArgumentError, "Another finalizer has already claimed the name #{name.inspect}" if self.map.has_key?(name)
    raise ArgumentError, "Name must be a symbol" unless name.kind_of?(Symbol)
    self.map[name] = finalizer
  end

  def self.map
    @_map ||= {}
  end

end

require File.dirname(__FILE__) + "/finalizers/zip"
require File.dirname(__FILE__) + "/finalizers/dir"
require File.dirname(__FILE__) + "/finalizers/rsync"
require File.dirname(__FILE__) + "/finalizers/git_branch"

