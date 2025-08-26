# frozen_string_literal: true

require 'rails/engine'

module ActiveAdmin
  module Trumbowyg
    class Engine < ::Rails::Engine
      engine_name 'activeadmin_trumbowyg'

      # Add our assets to the asset load paths
      initializer 'activeadmin_trumbowyg.assets' do |app|
        app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
        app.config.assets.paths << root.join('app', 'assets', 'javascripts')
        app.config.assets.paths << root.join('app', 'assets', 'fonts')
      end

      initializer 'activeadmin_trumbowyg.setup', after: :load_config_initializers do
        require 'active_admin' if defined?(Rails.application) && Rails.application
        # Load the Formtastic input directly
        require 'formtastic/inputs/trumbowyg_input'
        
        # Also hook into ActiveAdmin's load process
        ActiveSupport.on_load(:active_admin) do
          require 'formtastic/inputs/trumbowyg_input'
        end
      end
    end
  end
end
