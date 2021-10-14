class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:edit,:update]

  def show
    @user = User.find(params[:id])
    @category_names = Category.pluck(:name)
    params[:option] = 'ブックマーク' if params[:option].blank?
    params[:category_name] = '未選択' if params[:category_name].blank?
    @category = Category.find_by(name: params[:category_name])
    if @user.articles.present? || @user.bookmarks.present?
      if params[:option] == '投稿'
        if params[:category_name] == '未選択'
          duplicate_tag_names = @user.articles.map { |article| article.tags.pluck(:name) }.flatten
        else
          duplicate_tag_names = @user.articles.where(category_id: @category.id).map { |article| article.tags.pluck(:name) }.flatten
        end
      else
        if params[:category_name] == '未選択'
          article_ids = @user.article_bookmarks.pluck(:article_id)
          duplicate_tag_names = Article.where(id: article_ids).map { |article| article.tags.pluck(:name) }.flatten
        else
          article_ids = @user.article_bookmarks.pluck(:article_id)
          duplicate_tag_names = Article.where(id: article_ids, category_id: @category.id).map { |article| article.tags.pluck(:name) }.flatten
        end
      end
      itself_tag_names  = duplicate_tag_names.group_by(&:itself)
      hash_tag_names = itself_tag_names.map{ |key, value| [key, value.count] }.to_h
      sort_tag_names = hash_tag_names.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
      @results = sort_tag_names.map { |key, value| { tag: key, count: value } }
    end
    respond_to do |format|
      format.html
      format.js { render 'layouts/amcharts' }
    end
  end

  def index
    @users = User.order(id: 'DESC')
    @category_names = Category.pluck(:name)
    @article = Article.new
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
    params[:category_name] = '未選択' if params[:category_name].blank?
    @category_names = Category.pluck(:name)
    if params[:content].present?
      @tag_names = params[:content].split(',')
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.where(user_id: @user.id).order(id: 'DESC')
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(user_id: @user.id, category_id: @category.id).order(id: 'DESC')
        end
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
        @articles = @user.articles.where(id: sort_article_ids.keys).sort_by{ |a| sort_article_ids.keys.index(a.id)}
        # @articles = Kaminari.paginate_array(articles).page(params[:page]).per(7)
      end
    else
      if params[:category_name].present? && params[:category_name] != '未選択'
        @category = Category.find_by(name: params[:category_name])
        @articles = @user.articles.where(category_id: @category.id).order(id: 'DESC')
      else
        @article = Article.new
        @articles = @user.articles.order(id: 'DESC')
      end
    end
    if @user.articles.present?
      if params[:category_name].present? && params[:category_name] != '未選択'
        duplicate_tag_names = @user.articles.where(category_id: @category.id).map { |article| article.tags.pluck(:name) }.flatten
      else
        duplicate_tag_names = @user.articles.map { |article| article.tags.pluck(:name) }.flatten
      end
      itself_tag_names  = duplicate_tag_names.group_by(&:itself)
      hash_tag_names = itself_tag_names.map{ |key, value| [key, value.count] }.to_h
      sort_tag_names = hash_tag_names.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
      @results = sort_tag_names.map { |key, value| { tag: key, count: value } }
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

    respond_to do |format|
      format.html
      format.js { render 'articles/index' }
    end
  end

  def bookmarks
    @user = User.find(params[:id])
    params[:category_name] = '未選択' if params[:category_name].blank?
    @article_bookmarks_ids = @user.article_bookmarks.pluck(:article_id)
    @category_names = Category.pluck(:name)
    if params[:content].present?
      @tag_names = params[:content].split(',')
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.where(id: @article_bookmarks_ids).order(id: 'DESC')
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(id: @article_bookmarks_ids, category_id: @category.id).order(id: 'DESC')
        end
      else
        @tags = Tag.where(name: @tag_names)
        @category = Category.find_by(name: params[:category_name])
        if params[:category_name] == '未選択'
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: @article_bookmarks_ids)
        else
          category_articles = @category.articles.where(id: @article_bookmarks_ids)
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: category_articles)
        end
        @article_ids = @article_tags.pluck(:article_id)
        itself_article_ids  = @article_ids.group_by(&:itself)
        hash_article_ids = itself_article_ids.map{ |key, value| [key, value.count] }.to_h
        select_article_ids = hash_article_ids.select {|key, value| value >= 2 }
        sort_article_ids = select_article_ids.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h
        @articles = Article.where(id: sort_article_ids.keys).sort_by{ |a| sort_article_ids.keys.index(a.id)}
        # @articles = Kaminari.paginate_array(articles).page(params[:page]).per(7)
      end
    else
      if params[:category_name].present? && params[:category_name] != '未選択'
        @category = Category.find_by(name: params[:category_name])
        @articles = Article.where(id: @article_bookmarks_ids, category_id: @category.id).order(id: 'DESC')
      else
        @article = Article.new
        @articles = Article.where(id: @article_bookmarks_ids).order(id: 'DESC')
      end
    end

    if @article_bookmarks_ids.present?
      if params[:category_name].present? && params[:category_name] != '未選択'
        duplicate_tag_names = Article.where(id: @article_bookmarks_ids, category_id: @category.id).map { |article| article.tags.pluck(:name) }.flatten
      else
        duplicate_tag_names = Article.where(id: @article_bookmarks_ids).map { |article| article.tags.pluck(:name) }.flatten
      end
      itself_tag_names  = duplicate_tag_names.group_by(&:itself)
      hash_tag_names = itself_tag_names.map{ |key, value| [key, value.count] }.to_h
      sort_tag_names = hash_tag_names.sort {|(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
      @results = sort_tag_names.map { |key, value| { tag: key, count: value } }
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

    respond_to do |format|
      format.html
      format.js { render 'articles/index' }
    end
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
