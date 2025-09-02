# This file is used to run the test app in development mode
require 'bundler/setup'
require 'combustion'

ENV['RAILS_ENV'] ||= 'development'

Combustion.path = '.'
Combustion.initialize!(:all) do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

run Combustion::Application