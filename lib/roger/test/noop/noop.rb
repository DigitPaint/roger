require File.dirname(__FILE__) + "/lib/test"
require File.dirname(__FILE__) + "/lib/cli"

module Roger
  module Test
    module Noop
    end
  end
end

Roger::Test.register "noop", Roger::Test::Noop::Test