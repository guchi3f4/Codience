class ArticlesController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @article = Article.find(params[:id])
    @article_comment = ArticleComment.new
    @user = @article.user
    @results = Tag.all.map do |tag|
      { tag: tag.name, count: tag.articles.count }
    end
  end

  def index
    @category_names = Category.pluck(:name)
    @article = Article.new
    if params[:content].present?
      @tag_names = params[:content].split(',')
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        @articles = @tag.articles.order(id: 'DESC')
      else
        @tags = Tag.where(name: @tag_names)
        @article_tags = ArticleTag.where(tag_id: @tags)
        @article_ids = @article_tags.pluck(:article_id)
        itself_article_ids  = @article_ids.group_by(&:itself)
        hash_article_ids = itself_article_ids.map{ |key, value| [key, value.count] }.to_h
        select_article_ids = hash_article_ids.select {|key, value| value >= 2 }
        sort_article_ids = select_article_ids.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h
        @articles = Article.where(id: sort_article_ids.keys).sort_by{ |a| sort_article_ids.keys.index(a.id)}
        # @articles = Kaminari.paginate_array(articles).page(params[:page]).per(7)
      end
    else
      @articles = Article.order(id: 'DESC')
      @results = Tag.all.map do |tag|
        { tag: tag.name, count: tag.articles.count }
      end
    end
  end

  def new
    @article = Article.new
  end

  def create
    ApplicationRecord.transaction do
      @category = Category.find_or_create_by(name: params[:category_name])
      sent_tags = params[:tag_names].split(',')
      @article = Article.new(params_article)
      @article.save!
      @article.save_tag(sent_tags)

      @category_tags = @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
    end
    redirect_to article_path(@article)

  rescue ActiveRecord::RecordInvalid
    if request.referer.include?('/articles/new')
      render :new
    else
      @articles = Article.order(id: 'DESC')
      render :index
    end
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
      sent_tags = params[:tag_names].split(',')
      @article.update!(params_article)

      @article.save_tag(sent_tags)
      @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
    end
    redirect_to article_path(@article)
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
