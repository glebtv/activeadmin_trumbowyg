# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :author, optional: true

  validates :title, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description summary body author_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[author]
  end
end