class ArticleBookmarksController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    current_user.article_bookmarks.create(article_id: @article.id)
    render 'article_bookmarks/bookmark'
  end

  def destroy
    @article = Article.find(params[:article_id])
    current_user.article_bookmarks.find_by(article_id: @article.id).destroy
    render 'article_bookmarks/bookmark'
  end
end
