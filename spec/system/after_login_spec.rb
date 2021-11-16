# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザーログイン後のテスト', type: :system do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:article) { create(:article, user: user) }
  let!(:other_article) { create(:article, user: other_user) }
  let!(:tag) { create(:tag) }
  let!(:other_tag) { create(:tag) }
  let!(:article_tag) { ArticleTag.create(article: article, tag: tag) }
  let!(:other_article_tag) { ArticleTag.create(article: other_article, tag: other_tag) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'Log in'
  end

  describe 'ヘッダーのテスト' do

    context 'ヘッダーの表示を確認' do
      it 'ロゴが表示される' do
        expect(page).to have_selector "img[alt='header-logo']"
      end
      it 'Usersリンクが表示される' do
        expect(page).to have_selector 'a', text: 'Users'
      end
      it 'Mypageリンクが表示される' do
        expect(page).to have_selector 'a', text: 'Mypage'
      end
      it 'Articlesリンクが表示される' do
        expect(page).to have_selector 'a', text: 'Articles'
      end
      it 'Logoutリンクが表示される' do
        expect(page).to have_selector 'a', text: 'logout'
      end
      it 'Signupリンクが表示されない' do
        expect(page).not_to have_selector 'a', text: 'sign up'
      end
      it 'Loginリンクが表示されない' do
        expect(page).not_to have_selector 'a', text: 'login'
      end
    end

    context 'リンクの内容を確認' do
      it 'ロゴを押すと、Top画面に遷移' do
        click_on 'header-logo'
        expect(current_path).to eq root_path
      end
      it 'Usersリンクを押すと、ユーザー一覧に遷移' do
        click_link 'Users'
        expect(current_path).to eq users_path
      end
      it 'Mypageリンクを押すと、ログインユーザーの詳細画面に遷移' do
        click_link 'Mypage'
        expect(current_path).to eq user_path(user)
      end
      it 'Articlesリンクを押すと、記事一覧に遷移' do
        click_link 'Articles'
        expect(current_path).to eq articles_path
      end
      it 'Logoutリンクを押すと、Top画面遷移' do
        click_link 'logout'
        expect(current_path).to eq root_path
      end
      it 'Logoutリンクを押すと、Mypageリンクが表示されなくなる' do
        click_link 'logout'
        expect(page).not_to have_selector 'a', text: 'Mypage'
      end
    end
  end

  describe '記事一覧画面のテスト' do
    before do
      visit articles_path
    end

    describe 'サイドバーのテスト' do
      context 'Tagsを表示' do
        it '「Tags」と表示される' do
          expect(page).to have_content 'Tags'
        end
        it '「人気のタグ」と表示される' do
          expect(page).to have_content '人気のタグ'
        end
      end

      context 'ログインしたユーザーの情報を表示' do
        it '「User info」と表示される' do
          expect(page).to have_content 'User info'
        end
        it '画像が表示される' do
          expect(page).to have_selector "img[src$='#{user.profile_image}']"
        end
        it '画像のリンク先が正しい' do
          expect(page).to have_link '', href: user_path(user)
        end
        it 'ユーザーネームが表示され、リンク先が正しい' do
          expect(page).to have_link user.name, href: user_path(user)
        end
        it '「followers」と表示される' do
          expect(page).to have_content 'followers'
        end
        it 'followerの数が表示され、リンク先が正しい' do
          expect(page).to have_link user.followers.count.to_s, href: followers_user_path(user)
        end
        it '「followes」と表示される' do
          expect(page).to have_content 'followes'
        end
        it 'followした数が表示され、リンク先が正しい' do
          expect(page).to have_link user.following.count.to_s, href: following_user_path(user)
        end
        it '「投稿」と表示される' do
          expect(page).to have_content '投稿'
        end
        it '投稿した数が表示され、リンク先が正しい' do
          expect(page).to have_link user.articles.count.to_s, href: posts_user_path(user)
        end
        it '「ブックマーク」と表示される' do
          expect(page).to have_content 'ブックマーク'
        end
        it 'ブックマークした数が表示され、リンク先が正しい' do
          expect(page).to have_link user.article_bookmarks.count.to_s, href: bookmarks_user_path(user)
        end
        it '「被いいね」と表示される' do
          expect(page).to have_content '被いいね'
        end
        it 'いいねされた総数が表示され、リンク先が正しい' do
          expect(page).to have_link user.be_favorites_count.to_s, href: posts_user_path(user, sort_flag: 'いいね順')
        end
        it '「被ブックマーク」と表示される' do
          expect(page).to have_content '被ブックマーク'
        end
        it 'ブックマークされた総数が表示され、リンク先が正しい' do
          expect(page).to have_link user.be_bookmarks_count.to_s, href: posts_user_path(user, sort_flag: 'ブックマーク順')
        end
      end
    end

    describe '投稿一覧のテスト' do
      context '自分の投稿を表示' do
        it '画像が表示される' do
          expect(page).to have_selector "img[src$='#{article.user.profile_image}']"
        end
        it '画像のリンク先が正しい' do
          expect(page).to have_link '', href: user_path(article.user)
        end
        it 'タイトルが表示され、リンク先が正しい' do
          expect(page).to have_link article.title, href: article_path(article)
        end
        it 'Linkが表示され、リンク先が正しい' do
          expect(page).to have_link article.link, href: article.link
        end
        it '概要が表示されている' do
          expect(page).to have_content article.summary
        end
        it 'カテゴリーが表示され、リンク先が正しい' do
          expect(page).to have_link article.category.name, href: articles_path(category_name: article.category.name)
        end
        it 'タグが表示され、リンク先が正しい' do
          tag_name = article.tags.last.name
          expect(page).to have_link tag_name, href: articles_path(category_name: article.category.name, content: tag_name)
        end
      end

      context '他人の投稿を表示' do
        it '画像が表示される' do
          expect(page).to have_selector "img[src$='#{other_article.user.profile_image}']"
        end
        it '画像のリンク先が正しい' do
          expect(page).to have_link '', href: user_path(other_article.user)
        end
        it 'タイトルが表示され、リンク先が正しい' do
          expect(page).to have_link other_article.title, href: article_path(other_article)
        end
        it 'Linkが表示され、リンク先が正しい' do
          expect(page).to have_link other_article.link, href: other_article.link
        end
        it '概要が表示されている' do
          expect(page).to have_content other_article.summary
        end
        it 'カテゴリーが表示され、リンク先が正しい' do
          expect(page).to have_link other_article.category.name, href: articles_path(category_name: other_article.category.name)
        end
        it 'タグが表示され、リンク先が正しい' do
          tag_name = other_article.tags.last.name
          expect(page).to have_link tag_name, href: articles_path(category_name: other_article.category.name, content: tag_name)
        end
      end
    end
  end
end