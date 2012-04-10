require 'action_view/helpers/tags/collection_helpers'

module ActionView
  module Helpers
    module Tags
      class CollectionRadioButtons < Base
        include CollectionHelpers

        class RadioButtonBuilder < Builder
          def radio_button(extra_html_options={})
            html_options = extra_html_options.merge(@input_html_options)
            @template_object.radio_button(@object_name, @method_name, @value, html_options)
          end
        end

        def render
          render_collection do |item, value, text, default_html_options|
            builder = instantiate_builder(RadioButtonBuilder, item, value, text, default_html_options)

            if block_given?
              yield builder
            else
              builder.radio_button + builder.label
            end
          end
        end
      end
    end
  end
end
