class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :articles, dependent: :destroy
  has_many :article_comments, dependent: :destroy
  has_many :article_favorites, dependent: :destroy
  has_many :article_bookmarks, dependent: :destroy

  has_many :active_relations, class_name: "UserRelation", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relations, class_name: "UserRelation", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relations, source: :followed
  has_many :followers, through: :passive_relations, source: :follower
  attachment :profile_image

  validates :name,
    uniqueness: true,
    length:     { in: 2..20 }
  validates :introduction,
    length: { maximum: 100 }

  def be_favorites_count
    articles.map { |article| article.article_favorites.count }.sum
  end

  def be_bookmarks_count
    articles.map { |article| article.article_bookmarks.count }.sum
  end

  def following?(user)
    following.include?(user)
  end
end
