class ArticlesController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @article = Article.find(params[:id])
    @category_names = Category.pluck(:name)
    params[:category_name] = '未選択' if params[:category_name].blank?
    @article_comment = ArticleComment.new
    @user = @article.user
    # タグクラウドの表示
    @results = Tag.all.map do |tag|
      { tag: tag.name, count: tag.articles.count, show_count: tag.articles.count}
    end
  end

  def index
    @article = Article.new
    @category_names = Category.pluck(:name)
    params[:category_name] = '未選択' if params[:category_name].blank?
    # 検索にタグが入力されているか
    if params[:content].present?
      @tag_names = params[:content].split(',')
      # 検索タグが一つの場合
      if @tag_names.count == 1
        @tag = Tag.find_by(name: params[:content])
        if params[:category_name] == '未選択'
          @articles = @tag.articles.all
        else
          @category = Category.find_by(name: params[:category_name])
          @articles = @tag.articles.where(category_id: @category.id)
        end
      # 検索にタグが2つ以上の場合
      else
        @tags = Tag.where(name: @tag_names)
        @category = Category.find_by(name: params[:category_name])
        if params[:category_name] == '未選択'
          @article_tags = ArticleTag.where(tag_id: @tags)
        else
          @article_tags = ArticleTag.where(tag_id: @tags, article_id: @category.articles)
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
        @articles = Article.all
      else
        @category = Category.find_by(name: params[:category_name])
        @articles = @category.articles.all
      end
    end

    # タグクラウドの表示
    if params[:content].present?
      if @tag_names.count == 1
        duplicate_tag_names = @articles.map { |article| article.tags.pluck(:name) }.flatten
        itself_tag_names = duplicate_tag_names.group_by(&:itself)
        hash_tag_names = itself_tag_names.map { |key, value| [key, value.count] }.to_h
        sort_tag_names = hash_tag_names.sort { |(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
        @results = sort_tag_names.map do |key, value|
          tag = Tag.find_by(name: key)
          if params[:category_name] == '未選択'
            tag_count = tag.articles.count
          else
            tag_count = tag.articles.where(category_id: @category.id).count
          end
          { tag: key, count: value, show_count: tag_count }
        end
      else
        results_articles = Article.where(id: hash_article_ids.keys)
        duplicate_tag_names = results_articles.map { |article| article.tags.pluck(:name) }.flatten
        itself_tag_names = duplicate_tag_names.group_by(&:itself)
        hash_tag_names = itself_tag_names.map { |key, value| [key, value.count] }.to_h
        sort_tag_names = hash_tag_names.sort { |(_, v1), (_, v2)| v2 <=> v1 }.to_h.first(20)
        @results = sort_tag_names.map do |key, value|
          tag = Tag.find_by(name: key)
          tag_count = tag.articles.where(id: @article_ids).count
          { tag: key, count: value, show_count: tag_count }
        end
      end
    else
      if params[:category_name] == '未選択'
        @results = Tag.all.map do |tag|
          { tag: tag.name, count: tag.articles.count, show_count: tag.articles.count }
        end
      else
        @results = @category.category_tags.map do |category_tag|
          {
            tag:        category_tag.tag.name,
            count:      category_tag.registration_count,
            show_count: category_tag.registration_count,
          }
        end
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
  end

  def new
    @article = Article.new
    @category_names = Category.pluck(:name)
  end

  def create
    @category_names = Category.pluck(:name)
    ApplicationRecord.transaction do
      @category = Category.find_or_create_by(name: params[:category_name])
      @sent_tags = params[:tag_names].split(',')
      @article = Article.new(params_article)
      @article.save!
      # タグの処理
      raise ActiveRecord::RecordInvalid if @sent_tags.empty?
      @article.save_tag(@sent_tags)
      # カテゴリーの処理 カテゴリとタグの組み合わせをカウント
      @category_tags = @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
      redirect_to article_path(@article)
    end
  rescue ActiveRecord::RecordInvalid
    @article.errors.add(:tag_names, 'Tagを入力してください') if @sent_tags.empty?
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
    @category_names = Category.pluck(:name)
    ApplicationRecord.transaction do
      # 更新前のカテゴリ、タグの処理
      before_category = @article.category
      before_category_tags = before_category.category_tags.where(tag_id: @article.tags)
      before_category_tags.map do |category_tag|
        category_tag.update(registration_count: category_tag.registration_count -= 1)
      end

      @category = Category.find_or_create_by(name: params[:category_name])
      @sent_tags = params[:tag_names].split(',')
      @article.update!(params_article)
      # タグの処理
      raise ActiveRecord::RecordInvalid if @sent_tags.empty?
      @article.save_tag(@sent_tags)
      # カテゴリーの処理 カテゴリとタグの組み合わせをカウント
      @article.tags.map do |tag|
        category_tag = @category.category_tags.find_or_create_by(tag_id: tag.id)
        category_tag.update(registration_count: category_tag.registration_count += 1)
      end
      # 記事を一つも持たないタグを消去
      tag_ids = ArticleTag.pluck(:tag_id).uniq
      Tag.where.not(id: tag_ids).destroy_all
    end
    redirect_to article_path(@article)
  rescue ActiveRecord::RecordInvalid
    @article.errors.add(:tag_names, 'Tagを入力してください') if @sent_tags.empty?
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
    # 記事を一つも持たないタグを消去
    tag_ids = ArticleTag.pluck(:tag_id).uniq
    Tag.where.not(id: tag_ids).destroy_all

    redirect_to articles_path
  end

  private

  def params_article
    params.require(:article).permit(:title, :summary, :body, :link).merge(user_id: current_user.id, category_id: @category.id)
  end

  def ensure_correct_user
    @article = Article.find(params[:id])
    unless @article.user == current_user
      redirect_to articles_path
    end
  end
end
