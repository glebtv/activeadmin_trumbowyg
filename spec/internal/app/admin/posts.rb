# frozen_string_literal: true

# Ensure the Trumbowyg input is available
require 'formtastic/inputs/trumbowyg_input'

# Allowed HTML tags and attributes for Trumbowyg content sanitization
TRUMBOWYG_ALLOWED_TAGS = %w[
  p br strong em u s del ins a ul ol li
  h1 h2 h3 h4 h5 h6
  blockquote pre code img hr
  table thead tbody tr td th
].freeze
TRUMBOWYG_ALLOWED_ATTRIBUTES = %w[href src alt title class style].freeze

ActiveAdmin.register Post do
  permit_params :title, :description, :summary, :body, :author_id

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :created_at
    actions
  end

  filter :title
  filter :author
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :author
      f.input :description, as: :trumbowyg
      f.input :summary, as: :trumbowyg
      f.input :body, as: :trumbowyg
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :author
      row :description do |post|
        sanitize(post.description, tags: TRUMBOWYG_ALLOWED_TAGS, attributes: TRUMBOWYG_ALLOWED_ATTRIBUTES)
      end
      row :summary do |post|
        sanitize(post.summary, tags: TRUMBOWYG_ALLOWED_TAGS, attributes: TRUMBOWYG_ALLOWED_ATTRIBUTES)
      end
      row :body do |post|
        sanitize(post.body, tags: TRUMBOWYG_ALLOWED_TAGS, attributes: TRUMBOWYG_ALLOWED_ATTRIBUTES)
      end
      row :created_at
      row :updated_at
    end
  end
end
