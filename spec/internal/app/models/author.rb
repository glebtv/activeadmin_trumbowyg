# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[posts]
  end
end