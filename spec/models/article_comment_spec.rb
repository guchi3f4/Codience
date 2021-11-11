# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'article_commentモデルのテスト' do
  describe 'バリデーションのテスト' do
    let(:article_comment) { build(:article_comment) }

    context 'article_commentsテーブル' do
      it "有効な投稿内容の場合は保存されるか" do
        expect(article_comment).to be_valid
      end
    end

    context 'commentカラム' do
      it "空欄でないこと" do
        article_comment.comment = ''
        expect(article_comment).to be_invalid
      end
    end
  end
end