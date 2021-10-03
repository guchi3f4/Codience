class CreateCategoryTags < ActiveRecord::Migration[5.2]
  def change
    create_table :category_tags do |t|
      t.integer :category_id
      t.integer :tag_id
      t.integer :registration_count, default: 0

      t.timestamps
    end
  end
end
