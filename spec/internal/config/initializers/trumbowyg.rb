# frozen_string_literal: true

# Ensure the Trumbowyg input is loaded for Formtastic
Rails.application.config.after_initialize do
  require 'formtastic/inputs/trumbowyg_input'
end