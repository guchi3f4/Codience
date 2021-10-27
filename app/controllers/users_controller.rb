class UsersController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @category_names = Category.pluck(:name)
    params[:option] = 'ブックマーク' if params[:option].blank?
    params[:category_name] = '未選択' if params[:category_name].blank?
    @category = Category.find_by(name: params[:category_name])
    # タグクラウドの表示
    if defined?(@user.articles) || defined?(@user.bookmarks)
      if params[:option] == '投稿'
        if params[:category_name] == '未選択'
          @user_articles = @user.articles
        else
          @user_articles = @user.articles.where(category_id: @category.id)
        end
      else
        article_ids = @user.article_bookmarks.pluck(:article_id)
        if params[:category_name] == '未選択'
          @user_articles = Article.where(id: article_ids)
        else
          @user_articles = Article.where(id: article_ids, category_id: @category.id)
        end
      end
      duplicate_tag_names = @user_articles.map { |article| article.tags.pluck(:name) }.flatten
      itself_tag_names = duplicate_tag_names.group_by(&:itself)
      hash_tag_names = itself_tag_names.map { |key, value| [key, value.count] }.to_h
      sort_tag_names = hash_tag_names.sort { |(_, v1), (_, v2)| v1 <=> v2 }.to_h.first(20)
      sort_count = sort_tag_names.to_h.values.uniq
      @results = sort_tag_names.map { |key, value| { tag: key, count: sort_count.index(value), show_count: value } }
    end
    respond_to do |format|
      format.html
      format.js { render 'layouts/amcharts' }
    end
  end

  def index
    @users = User.page(params[:page]).per(9).order(id: 'DESC')
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
    @article = Article.new
    params[:category_name] = '未選択' if params[:category_name].blank?
    @category_names = Category.pluck(:name)
    # 検索タグが入力されているか
    if params[:content].present?
      @tag_names = params[:content].split(',')
      # 検索タグが一つの場合
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.where(user_id: @user.id)
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(user_id: @user.id, category_id: @category.id)
        end
      # 検索タグが2つ以上の場合
      else
        @tags = Tag.where(name: @tag_names)
        @category = Category.find_by(name: params[:category_name])
        if params[:category_name] == '未選択'
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: @user.articles)
        else
          user_category_articles = @user.articles.where(id: @category.articles)
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: user_category_articles)
        end
        @article_ids = @article_tags.pluck(:article_id)
        itself_article_ids = @article_ids.group_by(&:itself)
        hash_article_ids = itself_article_ids.map { |key, value| [key, value.count] }.to_h
        # 入力した値によって、検索したタグがいくつ一致するかが変動
        if params[:duplicate_num].blank? || params[:duplicate_num] == '全て'
          @duplicate_num = @tag_names.count
        else
          params[:duplicate_num] = @tag_names.count if params[:duplicate_num].to_i > @tag_names.count
          @duplicate_num = params[:duplicate_num].to_i
        end
        select_article_ids = hash_article_ids.select { |key, value| value >= @duplicate_num }
        @articles = Article.where(id: select_article_ids.keys)
      end
    # 検索タグが入力されていな場合
    else
      if params[:category_name] == '未選択'
        @articles = @user.articles.all
      else
        @category = Category.find_by(name: params[:category_name])
        @articles = @user.articles.where(category_id: @category.id)
      end
    end

    # タグクラウドの表示
    if defined?(@tag_names) && @tag_names.count >= 2
      results_articles = Article.where(id: hash_article_ids.keys)
      duplicate_tag_names = results_articles.map { |article| article.tags.pluck(:name) }.flatten
    else
      duplicate_tag_names = @articles.map { |article| article.tags.pluck(:name) }.flatten
    end
    itself_tag_names = duplicate_tag_names.group_by(&:itself)
    hash_tag_names = itself_tag_names.map { |key, value| [key, value.count] }.to_h
    sort_tag_names = hash_tag_names.sort { |(_, v1), (_, v2)| v1 <=> v2 }.last(12)
    sort_count = sort_tag_names.to_h.values.uniq
    if defined?(@tag_names) && @tag_names.count >= 2
      @results = sort_tag_names.map do |key, value|
        tag = Tag.find_by(name: key)
        tag_count = tag.articles.where(id: @article_ids).count
        { tag: key, count: sort_count.index(value), show_count: tag_count }
      end
    else
      @results = sort_tag_names.map do |key, value|
        tag = Tag.find_by(name: key)
        if params[:category_name] == '未選択'
          tag_count = tag.articles.where(user_id: @user).count
        else
          tag_count = tag.articles.where(user_id: @user, category_id: @category).count
        end
        { tag: key, count: sort_count.index(value), show_count: tag_count }
      end
    end

    # ソート機能
    case params[:sort_flag]
    when '新着順', nil then
      params[:sort_flag] = '新着順' if params[:sort_flag].nil?
      @articles = @articles.page(params[:page]).per(6).order(id: 'DESC')
    when 'いいね順' then
      @articles = @articles.sort { |a, b| b.article_favorites.count <=> a.article_favorites.count }
      @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
    when 'ブックマーク順' then
      @articles = @articles.sort { |a, b| b.article_bookmarks.size <=> a.article_bookmarks.size }
      @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
    when '関連度順' then
      if defined?(@tag_names) && @tag_names.count == 1
        params[:sort_flag] = '新着順'
        @articles = @articles.page(params[:page]).per(6).order(id: 'DESC')
      else
        sort_article_ids = select_article_ids.sort { |(_, v1), (_, v2)| v2 <=> v1 }.to_h
        @articles = @user.articles.where(id: sort_article_ids.keys).sort_by { |a| sort_article_ids.keys.index(a.id) }
        @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
      end
    end

    respond_to do |format|
      format.html
      format.js { render 'articles/index' }
    end
  end

  def bookmarks
    @user = User.find(params[:id])
    @article = Article.new
    params[:category_name] = '未選択' if params[:category_name].blank?
    @article_bookmarks_ids = @user.article_bookmarks.pluck(:article_id)
    @category_names = Category.pluck(:name)
    # 検索にタグが入力されているか
    if params[:content].present?
      @tag_names = params[:content].split(',')
      # 検索タグが一つの場合
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.where(id: @article_bookmarks_ids)
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(id: @article_bookmarks_ids, category_id: @category.id)
        end
      # 検索にタグが2つ以上の場合
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
        itself_article_ids = @article_ids.group_by(&:itself)
        hash_article_ids = itself_article_ids.map { |key, value| [key, value.count] }.to_h
        # 入力した値によって、検索したタグがいくつ一致するかが変動
        if params[:duplicate_num].blank? || params[:duplicate_num] == '全て'
          @duplicate_num = @tag_names.count
        else
          params[:duplicate_num] = @tag_names.count if params[:duplicate_num].to_i > @tag_names.count
          @duplicate_num = params[:duplicate_num].to_i
        end
        select_article_ids = hash_article_ids.select { |key, value| value >= @duplicate_num }
        @articles = Article.where(id: select_article_ids.keys)
      end
    # 検索にタグが入力されていな場合
    else
      if params[:category_name] == '未選択'
        @articles = Article.where(id: @article_bookmarks_ids)
      else
        @category = Category.find_by(name: params[:category_name])
        @articles = Article.where(id: @article_bookmarks_ids, category_id: @category.id)
      end
    end

    # タグクラウドの表示
    if defined?(@tag_names) && @tag_names.count >= 2
      results_articles = Article.where(id: hash_article_ids.keys)
      duplicate_tag_names = results_articles.map { |article| article.tags.pluck(:name) }.flatten
    else
      duplicate_tag_names = @articles.map { |article| article.tags.pluck(:name) }.flatten
    end
    itself_tag_names = duplicate_tag_names.group_by(&:itself)
    hash_tag_names = itself_tag_names.map { |key, value| [key, value.count] }.to_h
    sort_tag_names = hash_tag_names.sort { |(_, v1), (_, v2)| v1 <=> v2 }.last(12)
    sort_count = sort_tag_names.to_h.values.uniq
    if defined?(@tag_names) && @tag_names.count >= 2
      @results = sort_tag_names.map do |key, value|
        tag = Tag.find_by(name: key)
        tag_count = tag.articles.where(id: hash_article_ids.keys).count
        { tag: key, count: sort_count.index(value), show_count: tag_count }
      end
    else
      @results = sort_tag_names.map do |key, value|
        tag = Tag.find_by(name: key)
        if params[:category_name] == '未選択'
          tag_count = tag.articles.where(id: @article_bookmarks_ids).count
        else
          tag_count = tag.articles.where(id: @article_bookmarks_ids, category_id: @category).count
        end
        { tag: key, count: sort_count.index(value), show_count: tag_count }
      end
    end

    # ソート機能
    case params[:sort_flag]
    when '新着順', nil then
      params[:sort_flag] = '新着順' if params[:sort_flag].nil?
      @articles = @articles.page(params[:page]).per(6).order(id: 'DESC')
    when 'いいね順' then
      @articles = @articles.sort { |a, b| b.article_favorites.count <=> a.article_favorites.count }
      @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
    when 'ブックマーク順' then
      @articles = @articles.sort { |a, b| b.article_bookmarks.size <=> a.article_bookmarks.size }
      @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
    when '関連度順' then
      if defined?(@tag_names) && @tag_names.count == 1
        params[:sort_flag] = '新着順'
        @articles = @articles.page(params[:page]).per(6).order(id: 'DESC')
      else
        sort_article_ids = select_article_ids.sort { |(_, v1), (_, v2)| v2 <=> v1 }.to_h
        @articles = Article.where(id: sort_article_ids.keys).sort_by { |a| sort_article_ids.keys.index(a.id) }
        @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(6)
      end
    end

    respond_to do |format|
      format.html
      format.js { render 'articles/index' }
    end
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page]).per(6)
  end

  def following
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page]).per(6)
  end

  private

  def params_user
    params.require(:user).permit(:name, :profile_image, :introduction)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to root_path
    end
  end
end
