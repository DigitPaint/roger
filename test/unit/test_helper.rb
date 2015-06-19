if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require "simplecov"
  SimpleCov.start
end

require "test/unit"
require "mocha/test_unit"

require File.dirname(__FILE__) + "/../helpers/cli"
