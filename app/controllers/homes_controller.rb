class HomesController < ApplicationController
  def top
    @category_names = Category.pluck(:name)
    params[:category_name] = '未選択' if params[:category_name].blank?
    if params[:category_name] == '未選択'
      @article = Article.new
      @articles = Article.order(id: 'DESC')
      sort_tags = Tag.all.sort { |a, b| a.articles.count <=> b.articles.count }.last(20)
      sort_count = sort_tags.map { |tag| tag.articles.count }.uniq
      @results = sort_tags.map do |tag|
        {
          tag:        tag.name,
          count:      sort_count.index(tag.articles.count),
          show_count: tag.articles.count,
        }
      end
    else
      @category = Category.find_by(name: params[:category_name])
      @articles = @category.articles.order(id: 'DESC')
      sort_category_tags = @category.category_tags.sort { |a, b| a.registration_count <=> b.registration_count }.last(20)
      sort_count = sort_category_tags.pluck(:registration_count).uniq
      @results = sort_category_tags.map do |category_tag|
        {
          tag:        category_tag.tag.name,
          count:      sort_count.index(category_tag.registration_count),
          show_count: category_tag.registration_count,
        }
      end
    end
    respond_to do |format|
      format.html
      format.js { render 'layouts/amcharts' }
    end
  end
end
