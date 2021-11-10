# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'categoryモデルのテスト' do
  describe 'バリデーションのテスト' do
    let!(:other_category) { create(:category) }
    let(:category) { build(:category) }

    context 'categoriesテーブル' do
      it "有効な投稿内容の場合は保存されるか" do
        expect(category).to be_valid
      end
    end

    context 'nameカラム' do
      it '空欄でないこと' do
        category.name = ''
        expect(category).to be_invalid
      end
      it '一意性があること' do
        category.name = other_category.name
        expect(category).to be_invalid
      end
    end
  end
end