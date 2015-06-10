module Roger
  module Helpers
    module Logging
      # Write out a log message
      def log(part, msg, verbose = false, &_block)
        if !verbose || verbose && project.options[:verbose]
          project.shell.say "\033[37m#{part.class}\033[0m" + " : " + msg.to_s, nil, true
        end
        if block_given?
          begin
            project.shell.padding = project.shell.padding + 1
            yield
          ensure
            project.shell.padding = project.shell.padding - 1
          end
        end
      end

      def debug(part, msg, &block)
        log(part, msg, true, &block)
      end

      # Write out a warning message
      def warn(part, msg)
        project.shell.say "\033[37m#{part.class}\033[0m" + " : " + "\033[31m#{msg}\033[0m", nil, true
      end
    end
  end
end
