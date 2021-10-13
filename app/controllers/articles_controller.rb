class ArticlesController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @article = Article.find(params[:id])
    @category_names = Category.pluck(:name)
    @article_comment = ArticleComment.new
    @user = @article.user
    @results = Tag.all.map do |tag|
      { tag: tag.name, count: tag.articles.count }
    end
  end

  def index
    @category_names = Category.pluck(:name)
    if params[:content].present?
      @tag_names = params[:content].split(',')
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.order(id: 'DESC')
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(category_id: @category.id).order(id: 'DESC')
        end
        duplicate_tag_names = @articles.map { |article| article.tags.pluck(:name) }.flatten
      else
        @tags = Tag.where(name: @tag_names)
        @category = Category.find_by(name: params[:category_name])
        if params[:category_name] == '未選択'
          @article_tags = ArticleTag.where(tag_id: @tags)
        else
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: @category.articles)
        end
        @article_ids = @article_tags.pluck(:article_id)
        itself_article_ids  = @article_ids.group_by(&:itself)
        hash_article_ids = itself_article_ids.map{ |key, value| [key, value.count] }.to_h
        select_article_ids = hash_article_ids.select {|key, value| value >= 2 }
        sort_article_ids = select_article_ids.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h
        @articles = Article.where(id: sort_article_ids.keys).sort_by{ |a| sort_article_ids.keys.index(a.id)}
        # @articles = Kaminari.paginate_array(articles).page(params[:page]).per(7)

        results_articles = Article.where(id: hash_article_ids.keys)
        duplicate_tag_names = results_articles.map { |article| article.tags.pluck(:name) }.flatten
      end

      if duplicate_tag_names != 0
        itself_tag_names  = duplicate_tag_names.group_by(&:itself)
        hash_tag_names = itself_tag_names.map{ |key, value| [key, value.count] }.to_h
        sort_tag_names = hash_tag_names.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
        @results = sort_tag_names.map { |key, value| { tag: key, count: value } }
      else
        @results = @category.category_tags.map { |category_tag| { tag: category_tag.tag.name, count: category_tag.registration_count } }
      end

    else
      if params[:category_name].present? && params[:category_name] != '未選択'
        @category = Category.find_by(name: params[:category_name])
        @articles = @category.articles.order(id: 'DESC')
        @results = @category.category_tags.map { |category_tag| { tag: category_tag.tag.name, count: category_tag.registration_count } }
      else
        @article = Article.new
        @articles = Article.order(id: 'DESC')
        @results = Tag.all.map { |tag| { tag: tag.name, count: tag.articles.count } }
      end
    end

    case params[:sort_flag]
    when 'いいね順' then
      @articles = @articles.sort{ |a,b| b.article_favorites.count <=> a.article_favorites.count }
    when 'ブックマーク順' then
      @articles = @articles.sort{ |a,b| b.article_bookmarks.size <=> a.article_bookmarks.size }
    when '新着順'then
      if ( defined?(@tag_names) && @tag_names.count >= 2 )
        @articles = Article.where(id: select_article_ids.keys).order(id: 'DESC')
      end
    when '関連度順' then
      if ( defined?(@tag_names) && @tag_names.count == 1 )
        params[:sort_flag] = '新着順'
      end
    when nil then
      params[:sort_flag] = '新着順'
    end
  end

  def new
    @article = Article.new
    @category_names = Category.pluck(:name)
    # @select_category_names = Category.all.map { |category| [category.name, category.name]}
  end

  def create
    @category_names = Category.pluck(:name)
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
    @article_category_name = params[:category_name]
    @json_tag_names = params[:tag_names].split(',')
    render :new
  end

  def edit
    @article_category_name = @article.category.name
    @category_names = Category.pluck(:name)
    @json_tag_names = @article.tags.pluck(:name)
  end

  def update
    ApplicationRecord.transaction do
      @category_names = Category.pluck(:name)

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
    @article_category_name = params[:category_name]
    @json_tag_names = params[:tag_names].split(',')
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
