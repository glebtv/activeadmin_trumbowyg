# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.site_title = "Trumbowyg Test App"
  config.authentication_method = false
  config.current_user_method = false
  config.comments = false
  config.batch_actions = true
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
  config.localize_format = :long
end