class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  has_many :category_tags, dependent: :destroy
  has_many :categories, through: :category_tags

  validates :name, presence: true
end
