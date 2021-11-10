# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articleモデルのテスト' do
  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:category) { create(:category) }
    let!(:article) { build(:article, user_id: user.id, category_id: category.id) }

    context 'articlesテーブル' do
      it "有効な投稿内容の場合は保存されるか" do
        expect(article).to be_valid
      end
    end

    context 'titleカラム' do
      it '空欄でないこと' do
        article.title = ''
        expect(article).to be_invalid
      end
      it '7文字以上であること: 6文字は無効' do
        article.title = Faker::Lorem.characters(number: 6)
        expect(article).to be_invalid
      end
      it '7文字以上であること: 7文字は有効' do
        article.title = Faker::Lorem.characters(number: 7)
        expect(article).to be_valid
      end
      it '70文字以下であること: 70文字は有効' do
        article.title = Faker::Lorem.characters(number: 70)
        expect(article).to be_valid
      end
      it '70文字以下であること: 71文字は無効' do
        article.title = Faker::Lorem.characters(number: 71)
        expect(article).to be_invalid
      end
    end

    context 'linkカラム' do
      it '空欄でないこと' do
        article.link = ''
        expect(article).to be_invalid
      end
      it '値がurlであること: http,httpsで始まれば有効' do
        article.link = 'http://codience.work'
        expect(article).to be_valid

        article.link = 'https://codience.work'
        expect(article).to be_valid
      end
      it '値がurlであること: http,httpsでなければ無効' do
        article.link = 'codience.work'
        expect(article).to be_invalid
      end
    end
  end
end