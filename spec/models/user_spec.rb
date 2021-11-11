# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'userモデルのテスト' do
  describe 'バリデーションのテスト' do
    let!(:other_user) { create(:user) }
    let(:user) { build(:user) }

    context 'usersテーブル' do
      it "有効な投稿内容の場合は保存されるか" do
        expect(user).to be_valid
      end
    end

    context 'nameカラム' do
      it '空欄でないこと' do
        user.name = ''
        expect(user).to be_invalid
      end
      it '2文字以上であること: 1文字は無効' do
        user.name = Faker::Lorem.characters(number: 1)
        expect(user).to be_invalid
      end
      it '2文字以上であること: 2文字は有効' do
        user.name = Faker::Lorem.characters(number: 2)
        expect(user).to be_valid
      end
      it '20文字以下であること: 20文字は有効' do
        user.name = Faker::Lorem.characters(number: 20)
        expect(user).to be_valid
      end
      it '20文字以下であること: 21文字は無効' do
        user.name = Faker::Lorem.characters(number: 21)
        expect(user).to be_invalid
      end
      it '一意性があること' do
        user.name = other_user.name
        expect(user).to be_invalid
      end
    end

    context 'introductionカラム' do
      it '100文字以下であること: 100文字は有効' do
        user.introduction = Faker::Lorem.characters(number: 100)
        expect(user).to be_valid
      end
      it '100文字以下であること: 101文字は無効' do
        user.introduction = Faker::Lorem.characters(number: 101)
        expect(user).to be_invalid
      end
    end
  end
end