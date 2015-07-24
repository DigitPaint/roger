module Roger
  class Template
    module Helpers
      # The capture helper
      module Capture
        def self.included(base)
          # Just the writer; the reader is below.
          base.send(:attr_writer, :_content_for_blocks)
        end

        # Capture content in blocks in the template for later use in the layout.
        # Currently only works in ERB templates. Use like this in the template:
        #
        # ```
        #   <% content_for :name %> bla bla <% end %>
        # ```
        #
        # Place it like this in the layout:
        #
        # ```
        #   <%= yield :name %>
        # ```
        def content_for(block_name, &block)
          @_content_for_blocks ||= {}
          @_content_for_blocks[block_name] = capture(&block)
        end

        # rubocop:disable Lint/Eval
        def capture(&block)
          unless template.template.is_a?(Tilt::ERBTemplate)
            fail ArgumentError, "content_for works only with ERB Templates"
          end

          @block_counter ||= 0
          @block_counter += 1
          counter = @block_counter

          eval "@_erbout_tmp#{counter} = _erbout", block.binding
          eval "_erbout = \"\"", block.binding
          t = Tilt::ERBTemplate.new { "<%= yield %>" }
          t.render(&block)
        ensure
          eval "_erbout = @_erbout_tmp#{counter}", block.binding
        end
        # rubocop:enable Lint/Eval

        def _content_for_blocks
          @_content_for_blocks || {}
        end
      end
    end
  end
end
