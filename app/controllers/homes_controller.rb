class HomesController < ApplicationController
  def top
    @category_names = Category.pluck(:name)
    params[:category_name] = '未選択' if params[:category_name].blank?
    if params[:category_name] == '未選択'
      @article = Article.new
      @articles = Article.order(id: 'DESC')
      @results = Tag.all.map { |tag| { tag: tag.name, count: tag.articles.count } }
    else
      @category = Category.find_by(name: params[:category_name])
      @articles = @category.articles.order(id: 'DESC')
      @results = @category.category_tags.map { |category_tag| { tag: category_tag.tag.name, count: category_tag.registration_count } }
    end
    respond_to do |format|
      format.html
      format.js { render 'layouts/amcharts' }
    end
  end
end