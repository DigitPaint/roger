# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/roger/version"

Gem::Specification.new do |s|
  s.name = "roger"
  s.version = Roger::VERSION

  s.authors = ["Flurin Egger", "Edwin van der Graaf", "Joran Kapteijns"]
  s.email = ["info@digitpaint.nl", "flurin@digitpaint.nl"]
  s.homepage = "http://github.com/digitpaint/roger"
  s.summary = "Roger is a set of tools to create self-containing HTML mockups."
  s.description = "See homepage for more information."
  s.licenses = ["MIT"]

  s.date = Time.now.strftime("%Y-%m-%d")

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.extra_rdoc_files = [
    "README.md"
  ] + `git ls-files -- {doc}/*`.split("\n")

  s.rdoc_options = ["--charset=UTF-8"]

  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new(">= 0")
  end

  s.add_dependency("thor", ["~> 0.19.0"])
  s.add_dependency("rack", [">= 2.0.0"])
  s.add_dependency("tilt", ["~> 2.0.1"])
  s.add_dependency("mime-types", ["~> 3.1"])
  s.add_dependency("redcarpet", [">= 3.1.1"])
  s.add_dependency("test_construct", "~> 2.0")

  s.add_development_dependency("test-unit", "~> 3.0.0")
  s.add_development_dependency("mocha", "~> 1.1.0")
  s.add_development_dependency("simplecov", "~> 0.10.0")
  s.add_development_dependency("puma", "~> 3.12.0")
  s.add_development_dependency("rubocop", "~> 0.38.0")
end
