# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :active_admin_comments, force: true do |t|
    t.string :namespace
    t.text :body
    t.references :resource, polymorphic: true
    t.references :author, polymorphic: true
    t.timestamps
  end

  create_table :authors, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.text :description
    t.text :summary
    t.text :body
    t.references :author
    t.timestamps
  end
end
