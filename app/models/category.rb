class Category < ApplicationRecord
  has_many :articles

  has_many :category_tags, dependent: :destroy
  has_many :tags, through: :category_tags

  validates :name, presence: true
end
