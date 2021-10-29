class Api::ArticlesController < ApplicationController
  def index
    if params[:title_keyword].present?
      keyword = params[:title_keyword]
      titles = Article.where('title LIKE ?', "%#{keyword}%").pluck(:title)
      render json: titles
    else
      keyword = params[:keyword]
      if keyword.match(/[一-龠々]/) || keyword.match(/[\p{katakana}]/)
        tags = Tag.where(["name LIKE ?", "%#{keyword}%"]).pluck(:name)
      else
        tags = Tag.where(["conversion_name LIKE ?", "%#{keyword}%"]).pluck(:name)
      end
      render json: tags
    end
  end
end
