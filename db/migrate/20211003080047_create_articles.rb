class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.integer :user_id
      t.integer :category_id
      t.string :title
      t.string :link
      t.text :summary
      t.text :body
      t.integer :view_count, default: 0

      t.timestamps
    end
  end
end
