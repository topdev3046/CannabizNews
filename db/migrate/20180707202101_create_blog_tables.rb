class CreateBlogTables < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :blog do |t|
      t.string :title
      t.text :body
      t.string :slug
      t.decimal :num_views
      t.string :image
      t.boolean :published
      t.date :published_date
      t.integer :author_id
      t.timestamps
    end

    add_index :blog, :slug, unique: true
  end
end
