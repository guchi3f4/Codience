class Api::ArticlesController < ApplicationController
  def index
    keyword = params[:keyword]
    tags = Tag.where(["name LIKE ?", "%#{keyword}%"]).pluck(:name)
    render json: tags
  end
end
