class BlogFields < ActiveRecord::Migration
  def change
    add_column :blog, :sub_header, :string
    add_column :blog, :keywords, :string
    add_column :blog, :description, :string
  end
end
