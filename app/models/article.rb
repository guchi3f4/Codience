class Article < ApplicationRecord
  belongs_to :user
  has_many :article_comments, dependent: :destroy
  has_many :article_favorites, dependent: :destroy
  has_many :article_bookmarks, dependent: :destroy
  belongs_to :category
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  validates :title, presence: true
  validates :body,  presence: true
  validates :link,  presence: true

  def favorited_by?(user)
    article_favorites.where(user_id: user.id).exists?
  end

  def bookmarked_by?(user)
    article_bookmarks.where(user_id: user.id).exists?
  end

  def save_tag(sent_tags)
    if self.tags.present?
      self.tags.destroy_all
    end
    sent_tags.map do |tag|
      article_tag = Tag.find_or_create_by(name: tag)
      self.tags << article_tag
    end
  end
end