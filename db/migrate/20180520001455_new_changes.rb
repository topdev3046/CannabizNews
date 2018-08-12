class NewChanges < ActiveRecord::Migration
  def change
    create_table :product_states do |t|
      t.integer :product_id
      t.integer :state_id
      t.timestamps
    end

    create_table :vendor_states do |t|
      t.integer :product_id
      t.integer :state_id
      t.timestamps
    end
  end
end
