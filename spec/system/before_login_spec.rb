# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザーログイン前のテスト', type: :system do
  describe 'ヘッダーのテスト' do
    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'ロゴが表示される' do
        expect(page).to have_selector "img[alt='header-logo']"
      end
      it 'Usersリンクが表示される' do
        expect(page).to have_selector 'a', text: 'Users'
      end
      it 'Articlesリンクが表示される' do
        expect(page).to have_selector 'a', text: 'Articles'
      end
      it 'Signupリンクが表示される' do
        expect(page).to have_selector 'a', text: 'sign up'
      end
      it 'Loginリンクが表示される' do
        expect(page).to have_selector 'a', text: 'login'
      end
    end

    context "リンクの内容を確認" do
      it 'ロゴを押すと、Top画面に遷移' do
        click_on 'header-logo'
        expect(current_path).to eq root_path
      end
      it 'Usersリンクを押すと、ユーザー一覧に遷移' do
        click_link 'Users'
        expect(current_path).to eq users_path
      end
      it 'Articlesリンクを押すと、記事一覧に遷移' do
        click_link 'Articles'
        expect(current_path).to eq articles_path
      end
      it 'Signupリンクを押すと、新規登録画面に遷移' do
        click_link 'sign up'
        expect(current_path).to eq new_user_registration_path
      end
      it 'Usersリンクを押すと、ログイン画面に遷移' do
        click_link 'login'
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe 'ユーザ新規登録のテスト' do
    before do
      visit new_user_registration_path
    end

    context '表示内容の確認' do
      it '「Sign up」と表示される' do
        expect(page).to have_content 'Sign up'
      end
      it 'nameフォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'password_confirmationフォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it 'Sign upボタンが表示される' do
        expect(page).to have_button 'Sign up'
      end
      it 'Log inリンクが表示される' do
        expect(page).to have_link 'Log in'
      end
    end

    context 'リンクの内容を確認' do
      it 'Log inリンクを押すと、ログイン画面に遷移' do
        click_link 'Log in'
        expect(current_path).to eq new_user_session_path
      end
    end

    context '新規登録成功のテスト' do
      before do
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button 'Sign up' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できたユーザの詳細画面になっている' do
        click_button 'Sign up'
        expect(current_path).to eq user_path(User.last)
      end
    end
  end

  describe 'ユーザログインのテスト' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '表示内容の確認' do
      it '「Log in」と表示される' do
        expect(page).to have_content 'Log in'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'Log inボタンが表示される' do
        expect(page).to have_button 'Log in'
      end
      it 'Sign upリンクが表示される' do
        expect(page).to have_link 'Sign up'
      end
      it 'パスワード忘れた時用のリンクが表示される' do
        expect(page).to have_link 'パスワードをお忘れの方'
      end
    end

    context 'リンクの内容を確認' do
      it 'Sign upリンクを押すと、新規登録画面に遷移' do
        click_link 'Sign up'
        expect(current_path).to eq new_user_registration_path
      end
      it 'パスワード忘れた時用のリンクを押すと、パスワード再設定画面に遷移' do
        click_link 'パスワードをお忘れの方'
        expect(current_path).to eq new_user_password_path
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'ログイン後のリダイレクト先が、ログインしたユーザの詳細画面になっている' do
        expect(current_path).to eq user_path(user)
      end
    end
  end

  describe '記事一覧画面（サイドバー）のテスト' do
    before do
      visit articles_path
    end

    context '表示内容の確認' do
      it '「ようこそ、ゲストユーザーさん！」と表示される' do
        expect(page).to have_content 'ようこそ、'
        expect(page).to have_content 'ゲストユーザーさん！'
      end
      it '新規登録リンクがリンクが表示される' do
        expect(page).to have_link '新規登録'
      end
      it '「Sign up」と表示される' do
        expect(page).to have_content 'Sign up'
      end
      it 'nameフォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'password_confirmationフォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it 'Sign upボタンが表示される' do
        expect(page).to have_button 'Sign up'
      end
    end

    context 'リンクの内容を確認' do
      it '新規登録リンクを押すと、新規登録画面に遷移' do
        click_link '新規登録'
        expect(current_path).to eq new_user_registration_path
      end
    end

    context '新規登録成功のテスト' do
      before do
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button 'Sign up' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できたユーザの詳細画面になっている' do
        click_button 'Sign up'
        expect(current_path).to eq user_path(User.last)
      end
    end
  end

  describe '記事詳細画面のテスト' do
    let(:article) { create(:article) }

    before do
      visit article_path(article)
    end

    context '表示内容の確認' do
      it '送信ボタンが表示されない' do
        expect(page).not_to have_button '送信'
      end
      it '「コメントを投稿するには新規登録、ログインが必要です。」と表示される' do
        expect(page).to have_content 'コメントを投稿するには新規登録、ログインが必要です。'
      end
    end
  end
end