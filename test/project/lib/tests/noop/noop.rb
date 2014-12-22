require File.dirname(__FILE__) + "/lib/test"
require File.dirname(__FILE__) + "/lib/cli"

module RogerNoopTest
end

Roger::Test.register :noop, RogerNoopTest::Test