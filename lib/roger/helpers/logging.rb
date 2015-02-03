module Roger
  module Helpers
    module Logging
      # Write out a log message
      def log(part, msg, verbose = false, &block)
        if !verbose || verbose && self.project.options[:verbose]
          self.project.shell.say "\033[37m#{part.class.to_s}\033[0m" + " : " + msg.to_s, nil, true
        end
        if block_given?
          begin
            self.project.shell.padding = self.project.shell.padding + 1
            yield
          ensure
            self.project.shell.padding = self.project.shell.padding - 1
          end
        end
      end

      def debug(part, msg, &block)
        self.log(part, msg, true, &block)
      end

      # Write out a warning message
      def warn(part, msg)
        self.project.shell.say "\033[37m#{part.class.to_s}\033[0m" + " : " + "\033[31m#{msg.to_s}\033[0m", nil, true
      end

    end
  end
end