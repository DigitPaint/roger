module Roger
  module Helpers
    # Helper module for logging
    module Prompt
      def prompt
        Prompter.new(project.shell, project.options[:yes])
      end
    end

    # Actual implementation of the prompt methods
    class Prompter
      def initialize(shell, yes_flag)
        @shell = shell
        @yes_flag = yes_flag
      end

      def yes?(msg)
        if @yes_flag
          # Perhaps this should logged?
          true
        else
          @shell.yes? msg
        end
      end
    end
  end
end
