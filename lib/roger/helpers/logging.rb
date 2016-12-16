module Roger
  module Helpers
    # Helper module for logging
    module Logging
      GRAY = "\e[37m".freeze
      RED  = "\e[31m".freeze

      # Write out a log message
      def log(part, msg, verbose = false, &block)
        shell = project.shell

        if !verbose || verbose && project.options[:verbose]
          shell.say(
            shell.set_color(part_string(part), GRAY) +
            " : " +
            msg
          )
        end

        log_block_indent(&block) if block_given?
      end

      def debug(part, msg, &block)
        log(part, msg, true, &block)
      end

      # Write out a warning message
      def warn(part, msg)
        shell = project.shell

        shell.say(
          shell.set_color(part_string(part), GRAY) +
          " : " +
          shell.set_color(msg, RED)
        )
      end

      protected

      def part_string(part)
        part.is_a?(String) ? part : part.class.to_s
      end

      def log_block_indent(&_block)
        project.shell.padding = project.shell.padding + 1
        yield
      ensure
        project.shell.padding = project.shell.padding - 1
      end
    end
  end
end
