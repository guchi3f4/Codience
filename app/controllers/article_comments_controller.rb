class ArticleCommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @article_comment = @article.article_comments.new(article_comment_params)
    if @article_comment.save
      render 'comment' and return
    else
      render 'layouts/error'
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @article_comment = ArticleComment.find_by(id: params[:id], article_id: params[:article_id]).destroy
    render 'comment'
  end

  private

  def article_comment_params
    params.require(:article_comment).permit(:comment).merge(user_id: current_user.id)
  end
end
