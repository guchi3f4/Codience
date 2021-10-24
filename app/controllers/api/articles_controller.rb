class Api::ArticlesController < ApplicationController
  def index
    keyword = params[:keyword]
    if keyword.match(/[一-龠々]/)
      tags = Tag.where(["name LIKE ?", "%#{keyword}%"]).pluck(:name)
    else
      tags = Tag.where(["conversion_name LIKE ?", "%#{keyword}%"]).pluck(:name)
    end
    render json: tags
  end
end
