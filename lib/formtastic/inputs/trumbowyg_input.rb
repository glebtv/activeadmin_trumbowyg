# frozen_string_literal: true

module Formtastic
  module Inputs
    class TrumbowygInput < Formtastic::Inputs::TextInput
      def to_html
        input_wrapping do
          label_html << builder.text_area(method, input_html_options.merge(class: 'trumbowyg-input'))
        end
      end
      
      def input_html_options
        super.tap do |options|
          options[:class] = [options[:class], 'trumbowyg-input'].compact.join(' ')
        end
      end
    end
  end
end
