class FixVendorStates < ActiveRecord::Migration
  def change
    remove_column :vendor_states, :product_id
    add_column :vendor_states, :vendor_id, :integer
  end
end
