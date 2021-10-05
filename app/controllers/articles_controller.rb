class ArticlesController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @article = Article.find(params[:id])
    @article_comment = ArticleComment.new
  end

  def index
    @articles = Article.all
    @article = Article.new
  end

  def create
    ApplicationRecord.transaction do
      @category = Category.find_or_create_by(name: params[:category_name])
      sent_tags = params[:tag_name].split(',')
      @article = Article.new(params_article)
      @article.save!
      @article.save_tag(sent_tags)

      @category_tags = @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
    end
    redirect_to article_path(@article)
    flash[:notice] = 'You have created article successfully.'

  rescue ActiveRecord::RecordInvalid
    @articles = Article.order(id: 'DESC')
    render :index
  end

  def edit
    @category = @article.category
    @tag_names = @article.tags.pluck(:name)
    @join_tag_names = @tag_names.join(',')
  end

  def update
    ApplicationRecord.transaction do
      @before_category = @article.category
      @before_category_tags = @before_category.category_tags.where(tag_id: @article.tags)
      @before_category_tags.map do |category_tag|
        category_tag.update(registration_count: category_tag.registration_count -= 1)
      end

      @category = Category.find_or_create_by(name: params[:category_name])
      sent_tags = params[:tag_name].split(',')
      @article.update!(params_article)

      @article.save_tag(sent_tags)
      @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
    end
    redirect_to article_path(@article)
    flash[:notice] = "You have updated article successfully."
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  def destroy
    @category = @article.category
    @category_tags = @category.category_tags.where(tag_id: @article.tags)
    @category_tags.map do |category_tag|
      category_tag.update(registration_count: category_tag.registration_count -= 1)
    end
    @article.destroy
    redirect_to articles_path
  end

  private

  def params_article
    params.require(:article).permit(:title, :body, :link).merge(user_id: current_user.id, category_id: @category.id)
  end

  def ensure_correct_user
    @article = Article.find(params[:id])
    unless @article.user == current_user
      redirect_to articles_path
    end
  end
end
