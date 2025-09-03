# frozen_string_literal: true

require "rubygems"
require "bundler"

# Don't auto-require gems - we need to control loading order
Bundler.setup(:default, :development)

# Load Rails and combustion first
require 'combustion'

# Initialize Combustion with the Rails components we need
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

# Now that Rails is initialized, we can load ActiveAdmin and its dependencies
require 'importmap-rails'
require 'active_admin'
require 'activeadmin_trumbowyg'

# Ensure Formtastic input is loaded
require 'formtastic/inputs/trumbowyg_input'

run Combustion::Application
