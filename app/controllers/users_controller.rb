class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:edit,:update]

  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
  end

  def edit
  end

  def update
    if @user.update(params_user)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def posts
    @user = User.find(params[:id])
    @articles = @user.articles.order(id: 'DESC')
    @article = Article.new
  end

  def bookmarks
    @user = User.find(params[:id])
    @article_ids = current_user.article_bookmarks.where(article_id: @user.articles).pluck(:article_id)
    @articles = Article.where(id: @article_ids).order(id: 'DESC')
    @article = Article.new
  end

  def followers
    @users  = User.find(params[:id]).followers
  end

  def following
    @users  = User.find(params[:id]).following
  end

  private

  def params_user
    params.require(:user).permit(:name, :profile_image, :introduction)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
