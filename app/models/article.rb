class Article < ApplicationRecord
  belongs_to :user
  has_many :article_comments, dependent: :destroy
  has_many :article_favorites, dependent: :destroy
  has_many :article_bookmarks, dependent: :destroy
  belongs_to :category
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  validates :title, length: { in: 7..70 }
  validates :link,  presence: true
  validates :link, format: /\A#{URI::regexp(%w(http https))}\z/

  def favorited_by?(user)
    article_favorites.where(user_id: user.id).exists?
  end

  def bookmarked_by?(user)
    article_bookmarks.where(user_id: user.id).exists?
  end

  def save_tag(sent_tags)
    if tags.present?
      tags.destroy_all
    end

    sent_tags.map do |tag|
      # ひらがなに変換（補完機能用) gem: miyabi
      if tag.match(/[a-z0-9]/)
        conversion_name = tag
      else
        if tag.match(/[一-龠々]/)
          conversion_name = tag.to_kanhira.to_hira
        else
          conversion_name = tag.to_hira
        end
      end
      article_tag = Tag.find_or_create_by(name: tag, conversion_name: conversion_name)
      tags << article_tag
    end
  end
end
