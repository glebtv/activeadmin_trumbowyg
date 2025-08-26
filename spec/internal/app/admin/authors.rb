# frozen_string_literal: true

ActiveAdmin.register Author do
  permit_params :name, :email

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
    end
    f.actions
  end
end