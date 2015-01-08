require 'thor'
require 'thor/group'

module Roger
  module Generators

    class Base < Cli::Command
    end

    def self.register(name, sub = nil)
      # Hack to not break old tasks
      if name.kind_of?(Class)
        sub = name
        name = sub.to_s.sub(/Generator$/, "").sub(/^.*Generators::/,"").downcase
      else
        raise ArgumentError, "Name must be a symbol" unless name.kind_of?(Symbol)
      end

      name = name.to_s

      raise ArgumentError, "Another generator has already claimed the name #{name.inspect}" if Cli::Generate.tasks.has_key?(name)

      usage = "#{name} #{sub.arguments.map{ |arg| arg.banner }.join(" ")}"
      long_desc =  sub.desc || "Run #{name} generator"

      Cli::Generate.register sub, name, usage, long_desc
      Cli::Generate.tasks[name].options = sub.class_options if sub.class_options
    end

  end
end

# Default generators
require File.dirname(__FILE__) + "/generators/new"
require File.dirname(__FILE__) + "/generators/generator"