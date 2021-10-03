class CreateArticleBookmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :article_bookmarks do |t|
      t.integer :user_id
      t.integer :article_id

      t.timestamps
    end
  end
end
