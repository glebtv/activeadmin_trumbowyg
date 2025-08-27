# frozen_string_literal: true

ActiveAdmin.register Author do
  permit_params :name, :email, posts_attributes: [:id, :title, :description, :_destroy]

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :created_at
    actions
  end

  filter :name
  filter :email

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :email
      f.has_many :posts, allow_destroy: true, new_record: true do |p|
        p.input :title
        p.input :description, as: :text, input_html: { class: 'trumbowyg-input', 'data-aa-trumbowyg': true }
      end
    end
    f.actions
  end
end