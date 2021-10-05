class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :articles, dependent: :destroy
  has_many :article_comments, dependent: :destroy
  has_many :article_favorites, dependent: :destroy
  has_many :article_bookmarks, dependent: :destroy

  has_many :active_relation, class_name: "UserRelation", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relation, class_name: "UserRelation", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relation, source: :followed
  has_many :followers, through: :passive_relation, source: :follower
  attachment :profile_image
end
