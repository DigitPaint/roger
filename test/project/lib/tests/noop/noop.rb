require File.dirname(__FILE__) + "/lib/test"
require File.dirname(__FILE__) + "/lib/cli"

# RogerNoopTest namespace
module RogerNoopTest
end

Roger::Test.register :noop, RogerNoopTest::Test, RogerNoopTest::Cli
