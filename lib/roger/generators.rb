require "thor"
require "thor/group"

module Roger
  # Generators namespace
  module Generators
    # Base Generator class
    class Base < Cli::Command
      include Thor::Actions
    end

    def self.register(name, klass = nil)
      name, klass = generator_name(name, klass)

      if Cli::Generate.tasks.key?(name)
        raise(
          ArgumentError,
          "Generator name '#{name.inspect}' already in use"
        )
      end

      usage = "#{name} #{klass.arguments.map(&:banner).join(' ')}"
      long_desc = klass.desc || "Run #{name} generator"

      Cli::Generate.register klass, name, usage, long_desc
      Cli::Generate.tasks[name].options = klass.class_options if klass.class_options
    end

    def self.generator_name(name, klass)
      # Hack to not break old tasks

      if name.is_a?(Class)
        klass = name
        name = klass.to_s.sub(/Generator$/, "").sub(/^.*Generators::/, "").downcase
      else
        raise ArgumentError, "Name must be a symbol" unless name.is_a?(Symbol)
      end

      [name.to_s, klass]
    end
  end
end

# Default generators
require File.dirname(__FILE__) + "/generators/new"
require File.dirname(__FILE__) + "/generators/generator"
