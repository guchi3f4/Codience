class ArticleFavoritesController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    current_user.article_favorites.create(article_id: @article.id)
    render 'article_favorites/favorite'
  end

  def destroy
    @article = Article.find(params[:article_id])
    current_user.article_favorites.find_by(article_id: @article.id).destroy
    render 'article_favorites/favorite'
  end
end
