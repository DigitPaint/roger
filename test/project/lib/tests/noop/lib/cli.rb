module RogerNoopTest
  # A CLI command for the Noop test. Doesn't do anything
  class Cli < Roger::Test::Cli
    desc "init", "init noop tests"
    def init; end
  end
end
