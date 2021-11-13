require 'rails_helper'

RSpec.describe 'User CRUD処理', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'エラーメッセージの表示' do
    context 'ユーザー新規登録' do
      before do
        visit new_user_registration_path
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: 'test@mail'
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '投稿成功: フォームの入力値が正常' do
        click_button 'Sign up'
        expect(current_path).to eq user_path(User.last)
      end
      it '投稿失敗: ユーザーネームが1文字' do
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 1)
        click_button 'Sign up'
        expect(page).to have_content 'Nameは2文字以上で入力してください。'
      end
      it '投稿失敗: 登録済みのユーザーネーム' do
        fill_in 'user[name]', with: other_user.name
        click_button 'Sign up'
        expect(page).to have_content 'Nameがすでに使用されています'
      end
      it '投稿失敗: メールアドレス未記入' do
        fill_in 'user[email]', with: ''
        click_button 'Sign up'
        expect(page).to have_content 'Emailを入力してください'
      end
      it '投稿失敗: 登録済メールアドレス' do
        fill_in 'user[email]', with: other_user.email
        click_button 'Sign up'
        expect(page).to have_content 'Emailがすでに使用されています'
      end
      it '投稿失敗: パスワードの未入力' do
        fill_in 'user[password]', with: ''
        click_button 'Sign up'
        expect(page).to have_content 'Passwordを入力してください'
      end
      it '投稿失敗: パスワードが5文字' do
        fill_in 'user[password]', with: Faker::Lorem.characters(number: 5)
        click_button 'Sign up'
        expect(page).to have_content 'Passwordは6文字以上で入力してください'
      end
      it '投稿失敗: 確認用パスワードが一致しない' do
        fill_in 'user[password_confirmation]', with: 'Xassword'
        click_button 'Sign up'
        expect(page).to have_content 'Passwordが一致しません'
      end
    end

    context 'ユーザーログイン' do
    end
  end
end
