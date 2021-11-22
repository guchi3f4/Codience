# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザーログイン後のUser関連のテスト', type: :system do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:article) { create(:article, user: user) }
  let!(:other_article) { create(:article, user: other_user) }
  let!(:tag) { create(:tag) }
  let!(:other_tag) { create(:tag) }
  let!(:category) { create(:category) }
  let!(:other_category) { create(:category) }
  let!(:article_tag) { ArticleTag.create(article: article, tag: tag) }
  let!(:other_article_tag) { ArticleTag.create(article: other_article, tag: other_tag) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'Log in'
  end

  describe 'ユーザー一覧画面のテスト' do
    before do
      visit users_path
    end

    context '表示内容の確認' do
      it '「Users」と表示される' do
        expect(page).to have_content 'Users'
      end
      it '「followers」と表示される' do
        expect(page).to have_content 'followers'
      end
      it '「followes」と表示される' do
        expect(page).to have_content 'followes'
      end
      it '「投稿」と表示される' do
        expect(page).to have_content '投稿'
      end
      it '「ブックマーク」と表示される' do
        expect(page).to have_content 'ブックマーク'
      end
      it '「被いいね」と表示される' do
        expect(page).to have_content '被いいね'
      end
      it '「被ブックマーク」と表示される' do
        expect(page).to have_content '被ブックマーク'
      end
      it '「introduction」と表示される' do
        expect(page).to have_content 'introduction'
      end
    end

    context '自分のユーザー情報を表示' do
      it '画像が表示される' do
        expect(page).to have_selector "img[src$='#{user.profile_image.id}/profile_image']"
      end
      it '画像のリンク先が正しい' do
        expect(page).to have_link '', href: user_path(user)
      end
      it 'ユーザーネームが表示され、リンク先が正しい' do
        expect(page).to have_link user.name, href: user_path(user)
      end
      it '「フォローする」と表示されない' do
        expect(page).not_to have_link 'フォローする', href: user_user_relations_path(user.id)
      end
      it 'followerの数が表示され、リンク先が正しい' do
        expect(page).to have_link user.followers.count.to_s, href: followers_user_path(user)
      end
      it 'followした数が表示され、リンク先が正しい' do
        expect(page).to have_link user.following.count.to_s, href: following_user_path(user)
      end
      it '投稿した数が表示され、リンク先が正しい' do
        expect(page).to have_link user.articles.count.to_s, href: posts_user_path(user)
      end
      it 'ブックマークした数が表示され、リンク先が正しい' do
        expect(page).to have_link user.article_bookmarks.count.to_s, href: bookmarks_user_path(user)
      end
      it 'いいねされた総数が表示され、リンク先が正しい' do
        expect(page).to have_link user.be_favorites_count.to_s, href: posts_user_path(user, sort_flag: 'いいね順')
      end
      it 'ブックマークされた総数が表示され、リンク先が正しい' do
        expect(page).to have_link user.be_bookmarks_count.to_s, href: posts_user_path(user, sort_flag: 'ブックマーク順')
      end
      it '紹介文が表示される' do
        expect(page).to have_content user.introduction
      end
    end

    context '他人のユーザー情報を表示' do
      it '画像が表示される' do
        expect(page).to have_selector "img[src$='#{other_user.profile_image.id}/profile_image']"
      end
      it '画像のリンク先が正しい' do
        expect(page).to have_link '', href: user_path(other_user)
      end
      it 'ユーザーネームが表示され、リンク先が正しい' do
        expect(page).to have_link other_user.name, href: user_path(other_user)
      end
      it '「フォローする」と表示され、遷移先が正しい' do
        expect(page).to have_link 'フォローする', href: user_user_relations_path(other_user.id)
      end
      it 'followerの数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.followers.count.to_s, href: followers_user_path(other_user)
      end
      it 'followした数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.following.count.to_s, href: following_user_path(other_user)
      end
      it '投稿した数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.articles.count.to_s, href: posts_user_path(other_user)
      end
      it 'ブックマークした数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.article_bookmarks.count.to_s, href: bookmarks_user_path(other_user)
      end
      it 'いいねされた総数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.be_favorites_count.to_s, href: posts_user_path(other_user, sort_flag: 'いいね順')
      end
      it 'ブックマークされた総数が表示され、リンク先が正しい' do
        expect(page).to have_link other_user.be_bookmarks_count.to_s, href: posts_user_path(other_user, sort_flag: 'ブックマーク順')
      end
      it '紹介文が表示される' do
        expect(page).to have_content other_user.introduction
      end
    end

    describe 'フォロー機能のテスト', js: true do
      context '「フォローする」リンクをクリックした場合' do
        it '自分のフォローに保存される' do
          expect{ click_link 'フォローする' }.to change(user.following, :count).by(1)
        end
        it '相手のフォロワーに保存される' do
          expect{ click_link 'フォローする' }.to change(other_user.followers, :count).by(1)
        end
        it '表示が「フォローを外す」に変わる' do
          click_link 'フォローする'
          expect(page).to have_content 'フォローを外す'
        end
      end

      context '「フォロー外す」リンクをクリックした場合' do
        before do
          click_link 'フォローする'
        end

        it '自分のフォローに保存される' do
          expect{ click_link 'フォローを外す' }.to change(user.following, :count).by(-1)
        end
        it '相手のフォロワーに保存される' do
          expect{ click_link 'フォローを外す' }.to change(other_user.followers, :count).by(-1)
        end
        it '表示が「フォローを外す」に変わる' do
          click_link 'フォローを外す'
          expect(page).to have_content 'フォローする'
        end
      end
    end
  end

  describe 'ユーザー詳細画面のテスト' do
    before do
      visit user_path(user)
    end

    context 'ユーザー情報の表示' do
      it '「User Page」と表示される' do
        expect(page).to have_content 'User Page'
      end
      it '「User info」と表示される' do
        expect(page).to have_content 'User info'
      end
      it 'ユーザー編集画面へのリンクが存在する' do
        expect(page).to have_link '', href: edit_user_path(user)
      end
      it '新規投稿画面へのリンクが存在する' do
        expect(page).to have_selector "a.text-decoration-none[href='#{new_article_path}']"
      end
      it '「フォローする」と表示されない' do
        expect(page).not_to have_content 'フォローする'
      end
      it '他人のユーザー詳細ページの場合「フォローする」と表示される' do
        visit user_path(other_user)
        expect(page).to have_content 'フォローする'
      end
      it 'フォロワー一覧へのリンクが表示されている' do
        expect(page).to have_link 'フォロワー', href: followers_user_path(user)
      end
      it 'フォロ中のユーザー一覧へのリンクが表示されている' do
        expect(page).to have_link 'フォロー中', href: following_user_path(user)
      end
      it '自分の投稿一覧へのリンクが表示されている' do
        expect(page).to have_link '投稿一覧', href: posts_user_path(user)
      end
      it '自分がブックマークした一覧へのリンクが表示されている' do
        expect(page).to have_link 'ブックマーク一覧', href: bookmarks_user_path(user)
      end
    end

    context 'Tagsの表示', js: true do
      it '「Tags」と表示される' do
        expect(page).to have_content 'Tags'
      end
      it '「My登録タグ一覧」と表示される' do
        expect(page).to have_content 'My登録タグ一覧'
      end
      it 'Categoryフォームが表示される' do
        expect(page).to have_field 'category_name'
      end
      it 'Categoryフォームのセレクトボックスに「選択してください」と表示される' do
        expect(page).to have_selector 'select', text: '未選択'
      end
      it 'Categoryフォームが表示される' do
        expect(page).to have_field 'option'
      end
      it 'Categoryフォームのセレクトボックスに「ブックマーク」と表示される' do
        expect(page).to have_selector 'select', text: 'ブックマーク'
      end
    end
  end

  describe 'ユーザー編集画面のテスト' do
    describe '自分のユーザ情報編集画面のテスト' do
    before do
      visit edit_user_path(user)
    end

    context '表示の確認' do
      it '名前編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[name]', with: user.name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'user[profile_image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it 'Update Userボタンが表示される' do
        expect(page).to have_button 'Update User'
      end
    end

    context '更新成功のテスト' do
      before do
        @old_name = user.name
        @old_intrpduction = user.introduction
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 20)
        click_button 'Update User'
      end

      it 'nameが正しく更新される' do
        expect(user.reload.name).not_to eq @old_name
      end
      it 'introductionが正しく更新される' do
        expect(user.reload.introduction).not_to eq @old_intrpduction
      end
      it 'リダイレクト先が、自分のユーザ詳細画面になっている' do
        expect(current_path).to eq user_path(user)
        expect(page).to have_content 'User Page'
      end
    end
  end
  end
end