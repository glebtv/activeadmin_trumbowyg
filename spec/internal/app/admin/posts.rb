# frozen_string_literal: true

# Ensure the Trumbowyg input is available
require 'formtastic/inputs/trumbowyg_input'

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
      f.input :description, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
      f.input :summary, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
      f.input :body, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :author
      row :description do |post|
        # rubocop:todo Rails/OutputSafety -- TODO: Sanitize HTML content from Trumbowyg editor
        post.description&.html_safe
        # rubocop:enable Rails/OutputSafety
      end
      row :body do |post|
        # rubocop:todo Rails/OutputSafety -- TODO: Sanitize HTML content from Trumbowyg editor
        post.body&.html_safe
        # rubocop:enable Rails/OutputSafety
      end
      row :created_at
      row :updated_at
    end
  end
end
